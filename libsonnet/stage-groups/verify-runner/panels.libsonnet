local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';
local heatmapPanel = grafana.heatmapPanel;
local promQuery = import 'grafana/prom_query.libsonnet';

local heatmap(
  title,
  query,
  interval='$__rate_interval',
  intervalFactor=3,
  color_mode='opacity',  // alowed are: opacity, spectrum
  color_cardColor='#FA6400',  // used when color_mode='opacity' is set
  color_colorScheme='Oranges',  // used when color_mode='spectrum' is set
  color_exponent=0.5,
  legend_show=false,
      ) =
  heatmapPanel.new(
    title=title,
    datasource='$PROMETHEUS_DS',
    legend_show=legend_show,
    yAxis_format='s',
    dataFormat='tsbuckets',
    yAxis_decimals=2,
    color_mode=color_mode,
    color_cardColor=color_cardColor,
    color_colorScheme=color_colorScheme,
    color_exponent=color_exponent,
    cards_cardPadding=1,
    cards_cardRound=2,
    tooltipDecimals=3,
    tooltip_showHistogram=true,
  )
  .addTarget(
    promQuery.target(
      query,
      format='time_series',
      legendFormat='{{le}}',
      interval=interval,
      intervalFactor=intervalFactor,
    ) + {
      dsType: 'influxdb',
      format: 'heatmap',
      orderByTime: 'ASC',
      groupBy: [
        {
          params: ['$__rate_interval'],
          type: 'time',
        },
        {
          params: ['null'],
          type: 'fill',
        },
      ],
      select: [
        [
          {
            params: ['value'],
            type: 'field',
          },
          {
            params: [],
            type: 'mean',
          },
        ],
      ],
    }
  );

{
  heatmap:: heatmap,
}
