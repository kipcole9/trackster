function TracksterChart() {
   this.area = function(container, title, series_data, options) {
	   return chart = new Highcharts.Chart({
	      chart: {
	         renderTo: container, 
	         defaultSeriesType: 'area'
	      },
	      title: {
	         text: title
	      },
	      subtitle: {
	         text: options.subtitle
	      },
	      xAxis: {
			 title: {
				text: options.x_axis.title
			 }
	         labels: {
	            formatter: function() {
	               return this.value;
	            }
	         }                     
	      },
	      yAxis: {
	         title: {
	            text: options.y_axis.title
	         },
	         labels: {
	            formatter: function() {
	               return this.value;
	            }
	         }
	      },
	      tooltip: {
	         formatter: function() {
	            return this.series.name +' produced <b>'+
	               Highcharts.numberFormat(this.y, 0) +'</b><br/>warheads in '+ this.x;
	         }
	      },
	      plotOptions: {
	         area: {
	            pointStart: 1940,
	            marker: {
	               enabled: false,
	               symbol: 'circle',
	               radius: 2,
	               states: {
	                  hover: {
	                     enabled: true
	                  }
	               }
	            }
	         }
	      },
	      series: [{
	         name: series_data.name,
	         data: series_data.data
	      }]
	   });
	};
};

var chart = TracksterChart.area('chart', 'Test Chart', 
	{	
		name: 'stuff', 
		data: [1,2,3,4,5,6,7]
	}, 
	{
		x_axis: {title: 'X Axis Title'}, 
		y_axis: {title: 'Y Axis Title'}
	}
)