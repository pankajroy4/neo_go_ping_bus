import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['chart', 'chart2', 'chart3'];
  static values = { arr: Array }

  connect() {
    console.log(this.arrValue)
    const options = {
      download: true,
      library: {
        scales: {
          yAxes: [{
            ticks: {
              callback: function(value) {
                if (Number.isInteger(value) && value >= 0) {
                  return value;
                }
              }
            }
          }]
        }
      }
    };

    new Chartkick.AreaChart(this.chartTarget, this.arrValue, options);
    new Chartkick.LineChart(this.chart2Target, this.arrValue, {...options, curve: false});
    new Chartkick.ColumnChart(this.chart3Target, this.arrValue, options);
  }
}