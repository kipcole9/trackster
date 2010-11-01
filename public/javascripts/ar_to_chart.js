function arToChart() {
   // Set up the various colours we want to use here
	var self = this;

   	// Add some hidden structure that we can then use to get color and style information from
   	var template = "<div style='display:none;width=1em'><p id=highcharts>&nbsp</p>" + 
				  "<p id=highcharts-text>&npsb</p><p id=highcharts-area>&npsb</p>" +
				  "<p id=highcharts-line>&npsb</p><p id=highcharts-gridlines>&npsb</p>" + 
				  "<p id=highcharts-axis>&npsb</p><p id=highcharts-xbands>&npsb</p></div>";
   	$('body').append(template);
   
	this.font = {
		size:   $('#highcharts-text').css('font-size'),
		family: $('#highcharts-text').css('font-family'),
		weight: $('#highcharts-text').css('font-weight'),
		color:  $('#highcharts-text').css('color')
   	}

   	this.lineWeight = {
		grid:   1,
		axis:   1
   	}

   	this.colors = {
		background:  $('#highcharts').css('background-color'), 
	  	areaFill:    $('#highcharts-area').css('color'),
		areaOpacity: $('#highcharts-area').css('opacity'),
		gridLines:   $('#highcharts-gridlines').css('color'),
		lineColor:   $('#highcharts-line').css('color'),
		xAxisLine:   $('#highcharts-axis').css('color'),
		yAxisLine: 	 $('#highcharts-axis').css('color'),
		plotBands: 	 $('#highcharts-xbands').css('color')  
   	};

	function will_print() {
		return window.location.href.match(/print=/) || pdf_export();
	}
	
	function pdf_export() {
		return $('meta[name=pdf-output]').length > 0;
	}
	
	function getLineWidth(series) {
		if (pdf_export) {
			return 1; 
		} else {
			return (series.length > 50) ? 1 : self.lineWeight.axis;
		}
	}

	// Render an Area chart with one or more data series
   	this.area = function(container, categories, series_data, options) {

		/* Put colors into plotbands */
		if (options.x_plot_bands) {
			$(options.x_plot_bands).each(function(index, item) {
				item.color = self.colors.plotBands;
			});
		};

		return chart = new Highcharts.Chart({
			chart: {
				credits: 			{ 
					enabled: false
				},
				borderWidth: 		0,
				borderColor: 		self.colors.background,
	         	renderTo: 			container, 
	         	defaultSeriesType: 'area',
			 	backgroundColor: 	self.colors.background,
			 	marginTop: 			15,
			 	zoomType: 		    'x'
	      	},
		    navigation: {
		        buttonOptions: {
		            backgroundColor: self.colors.background
		        }
			},
			exporting: {
				enabled: !will_print()
		    },
	      	title: {
	        	text: options.title || ''
	      	},
	      	subtitle: {
	        	text: options.subtitle || ''
	      	},
	      	xAxis: {
			 	type: 				(categories ? 'linear' : 'datetime'),
			 	categories:    		categories,
			 	gridLineColor: 		self.colors.gridLines,
			 	gridLineWidth: 		(series_data[0].data.length > 50) ? 0 : self.lineWeight.grid,
			 	lineColor:     		self.colors.xAxisLine,
			 	lineWidth:     		getLineWidth(series_data[0].data),
			 	title: {
					text: options.x_axis || ''
			 	},
				labels: {
					step: 			options.x_step || 1,
					staggerLines: 	options.staggerLines || 1, 
					style: {
						fontSize: 	self.font.size,
						fontFamily: self.font.family,
						fontWeight: self.font.weight,
						color:      self.font.color
					},
	            	formatter: function() {
						return this.value; 
	            	}
	         	},
	            plotBands: options.x_plot_bands
	      	},
	      	yAxis: {
				gridLineColor: self.colors.gridLines,
			 	gridLineWidth: self.lineWeight.grid,
			 	lineColor:     self.colors.yAxisLine,
			 	lineWidth:     self.lineWeight.axis,
	         	title: {
	            	text: options.y_axis || ''
	         	},
	         	labels: {
					style: {
						fontSize:   self.font.size,
						fontFamily: self.font.family,
						fontWeight: self.font.weight,
						color:      self.font.color
					},
	            	formatter: function() {
	               		return this.value;
	            	}
	         	}
	      	},
	      	tooltip: {
	        	formatter: function() {
					if (this.series.type == 'pie') {
						return this.series.name + ':<br>' + this.point.name + ": " + Highcharts.numberFormat(this.y, 0)
					} else {
	            		return 'On: ' + this.x + "<br>" + this.series.name +': ' + Highcharts.numberFormat(this.y, 0)
					}
	         	}
	      	},
		  	legend: {
				enabled: (series_data.size > 1)
		  	},
	      	plotOptions: {
				series: {
					enableMouseTracking: !will_print(), 
					shadow: 			 false, 
					animation: 			 !will_print()
				},
	        	area: {
			    	fillColor: self.colors.areaFill,
			    	color: 	   self.colors.lineColor,
					lineWidth: 3,
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
	        	},
				pie: {
				    allowPointSelect: true,
		            cursor: 'pointer',
		            dataLabels: {
		               enabled: true,
		               formatter: function() {
		                  if (this.y > 0) return this.point.name + ": " + Highcharts.numberFormat(this.percentage, 1) +'%';
		               },
		               color: self.font.color
		            }
		        }
	      	},
	      	series: series_data
	   	});
	};
	
	// Render a Pie chart
	this.pie = function(container, categories, series_data, options) {
		this.area(container, categories, series_data, options);
	}
	
	// Render Funnel chart
   	this.funnel = function(container, categories, series_data, options) {
		return chart = new Highcharts.Chart({
			chart: {
				backgroundColor: 	self.colors.background,
				borderWidth: 		0,
				borderColor: 		self.colors.background,
				renderTo: 			container,
				defaultSeriesType: 	'funnel',
				margin: 			[20, 100, 40, 180]
			},
			navigation: {
		        buttonOptions: {
		            backgroundColor: self.colors.background
		        }
		    },
			title: {
				text: options.title || ''
			},
			subtitle: {
	        	text: options.subtitle || ''
	      	},
			plotArea: {
				shadow: 			null,
				borderWidth: 		null,
				backgroundColor: 	null
			},
			tooltip: {
				formatter: function() {
					return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.y, 0);
				}
			},
			plotOptions: {
				series: {
					dataLabels: {
						align: 		'left',
						x: 			-300,
						enabled: 	true,
						color: 		self.font.color,
						formatter: function() {
							return '<b>'+ this.point.name +'</b> ('+ Highcharts.numberFormat(this.point.y, 0) +')';
						}
					}
				}
			},
			legend: {
				enabled: false
			},
		    series: series_data
		});
	};
};
