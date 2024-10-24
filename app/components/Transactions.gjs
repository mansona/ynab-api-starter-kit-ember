import { utils } from 'ynab';

function convertconvertMilliUnitsToCurrencyAmount(amount) {
  return utils.convertMilliUnitsToCurrencyAmount(amount).toFixed(2);
}

<template>
  <div class="container">
    <h5>Transactions</h5>
    <table class="table">
      <thead>
        <tr>
          <th>Account</th>
          <th>Date</th>
          <th>Payee</th>
          <th>Category</th>
          <th>Memo</th>
          <th>Amount</th>
        </tr>
      </thead>
      <tbody>
        {{#each @transactions as |transaction|}}
          <tr>
            <td>{{transaction.account_name}}</td>
            <td>{{transaction.date}}</td>
            <td>{{transaction.payee_name}}</td>
            <td>{{transaction.category_name}}</td>
            <td>{{transaction.memo}}</td>
            <td>{{convertconvertMilliUnitsToCurrencyAmount
                transaction.amount
              }}</td>
          </tr>
        {{/each}}
      </tbody>
    </table>
  </div>
</template>
