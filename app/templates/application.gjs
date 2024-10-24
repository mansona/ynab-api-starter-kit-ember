import RouteTemplate from 'ember-route-template';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { action } from '@ember/object';

import 'github-fork-ribbon-css/gh-fork-ribbon.css';
import 'bootswatch/dist/flatly/bootstrap.css';

// Hooray! Here comes YNAB!
import * as ynab from 'ynab';

// Import our config for YNAB
import config from '../config/environment';

// Import Our Components to Compose Our App
import Nav from '../components/Nav';
import Footer from '../components/Footer';
import Budgets from '../components/Budgets';
import Transactions from '../components/Transactions';

// This adapter converts the `<template>` into a route template
class ApplicationRouteComponent extends Component {
  @tracked
  ynab = {
    clientId: config.clientId,
    redirectUri: encodeURIComponent(config.redirectUri),
    token: null,
    api: null,
  };

  @tracked loading = false;
  @tracked error = null;
  @tracked budgetId = null;
  @tracked budgets = [];
  @tracked transactions = [];

  // This uses the YNAB API to get a list of budgets
  getBudgets() {
    this.loading = true;
    this.error = null;
    this.api.budgets
      .getBudgets()
      .then((res) => {
        this.budgets = res.data.budgets;
      })
      .catch((err) => {
        this.error = err.error.detail;
      })
      .finally(() => {
        this.loading = false;
      });
  }
  // This selects a budget and gets all the transactions in that budget
  @action
  async selectBudget(id) {
    this.loading = true;
    this.error = null;
    this.budgetId = id;
    this.transactions = [];

    try {
      const res = await this.api.transactions.getTransactions(id);

      this.transactions = res.data.transactions;
    } catch (err) {
      this.error = err.error.detail;
    } finally {
      this.loading = false;
    }
  }

  // Method to find a YNAB token
  // First it looks in the location.hash and then sessionStorage
  findYNABToken() {
    let token = null;
    const search = window.location.hash
      .substring(1)
      .replace(/&/g, '","')
      .replace(/=/g, '":"');
    if (search && search !== '') {
      // Try to get access_token from the hash returned by OAuth
      const params = JSON.parse('{"' + search + '"}', function (key, value) {
        return key === '' ? value : decodeURIComponent(value);
      });
      token = params.access_token;
      sessionStorage.setItem('ynab_access_token', token);
      window.location.hash = '';
    } else {
      // Otherwise try sessionStorage
      token = sessionStorage.getItem('ynab_access_token');
    }
    return token;
  }
  // Clear the token and start authorization over
  resetToken() {
    sessionStorage.removeItem('ynab_access_token');
    this.ynab.token = null;
    this.error = null;
  }

  @action
  resetBudgetId() {
    this.budgetId = null;
  }

  // When this component is created, check whether we need to get a token,
  // budgets or display the transactions
  constructor() {
    super(...arguments);
    this.ynab.token = this.findYNABToken();
    if (this.ynab.token) {
      this.api = new ynab.api(this.ynab.token);
      if (!this.budgetId) {
        this.getBudgets();
      } else {
        this.selectBudget(this.budgetId);
      }
    }
  }

  <template>
    <div id="app">
      <a
        class="github-fork-ribbon"
        href="https://url.to-your.repo"
        data-ribbon="Fork me on GitHub"
      >Fork me on GitHub</a>

      <Nav />
      <div class="container">

        {{#if this.loading}}
          <!-- Display a loading message if loading -->
          <h1 class="display-4">Loading...</h1>

          <!-- Display an error if we got one -->
        {{else if this.error}}
          <h1 class="display-4">Oops!</h1>
          <p class="lead">{{this.error}}</p>
          <button
            class="btn btn-primary"
            type="button"
            {{on "click" this.resetToken}}
          >Try Again &gt;</button>

        {{else}}

          <!-- Otherwise show our app contents -->
          <div>

            {{#if this.ynab.token}}
              {{#if this.budgetId}}
                <!-- If a budget has been selected, display transactions from that budget -->
                <div>
                  <Transactions @transactions={{this.transactions}} />
                  <button
                    class="btn btn-info"
                    type="button"
                    {{on "click" this.resetBudgetId}}
                  >&lt; Select Another Budget</button>
                </div>
              {{else}}
                <!-- Otherwise if we have a token, show the budget select -->
                <Budgets
                  @budgets={{this.budgets}}
                  @selectBudget={{this.selectBudget}}
                />
              {{/if}}
            {{else}}
              <!-- If we dont have a token ask the user to authorize with YNAB -->
              <form>
                <h1 class="display-4">Congrats!</h1>
                <p class="lead">You have successfully initialized a new YNAB API
                  Application!</p>
                <p>The next step is the OAuth configuration, you can
                  <a
                    href="https://github.com/ynab/ynab-api-starter-kit#step-2-obtain-an-oauth-client-id-so-the-app-can-access-the-ynab-api"
                  >read detailed instructions in the README.md</a>. Essentially:</p>
                <ul>
                  <li>Make sure to be logged into your YNAB account, go to your
                    <a
                      href="https://app.ynab.com/settings/developer"
                      target="_blank"
                      rel="noopener noreferrer"
                    >YNAB Developer Settings</a>
                    and create a new OAuth Application.</li>
                  <li>Enter the URL of this project as a Redirect URI (in
                    addition to the existing three options), then "Save
                    Application."</li>
                  <li>Copy your Client ID and Redirect URI into the
                    <em>src/config.json</em>
                    file of your project.</li>
                  <li>Then build your amazing app!</li>
                </ul>
                <p>If you have any questions please reach out to us at
                  <strong>api@ynab.com</strong>.</p>
                <p>&nbsp;</p>

                <div class="form-group">
                  <h2>Hello!</h2>
                  <p class="lead">If you would like to use this App, please
                    authorize with YNAB!</p>
                  <a
                    href="https://app.ynab.com/oauth/authorize?client_id={{this.ynab.clientId}}&redirect_uri={{this.ynab.redirectUri}}&response_type=token"
                    class="btn btn-primary"
                  >Authorize This App With YNAB &gt;</a>
                </div>
              </form>
            {{/if}}

          </div>
        {{/if}}

        <Footer />
      </div>
    </div>
  </template>
}

export default RouteTemplate(ApplicationRouteComponent);
