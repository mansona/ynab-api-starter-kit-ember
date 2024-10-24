import { on } from '@ember/modifier';
import { fn } from '@ember/helper';

<template>
  <div class="budgets container">
    <h5>Select A Budget</h5>
    {{#each @budgets as |budget|}}
      <div class="row">
        <a class="col" href="#" {{on "click" (fn @selectBudget budget.id)}}>
          {{budget.name}}
        </a>
      </div>
    {{/each}}
  </div>
</template>
