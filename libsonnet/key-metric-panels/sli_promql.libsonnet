local multiburnFactors = import 'mwmbr/multiburn_factors.libsonnet';
local aggregations = import 'promql/aggregations.libsonnet';
local selectors = import 'promql/selectors.libsonnet';

local globalSelector = { monitor: 'global' };

local apdexQuery(aggregationSet, aggregationLabels, selectorHash, range=null, worstCase=true, offset=null, clampToExpression=null) =
  local metric = aggregationSet.getApdexRatioMetricForBurnRate('5m');
  local selector = selectors.merge(aggregationSet.selector, selectorHash);

  local aggregation = if worstCase then 'min' else 'avg';
  local rangeVectorFunction = if worstCase then 'min_over_time' else 'avg_over_time';
  local offsetExpression = if offset == null then '' else ' offset ' + offset;

  local formatConfig = {
    range: range,
    metric: metric,
    selector: selectors.serializeHash(selector),
    rangeVectorFunction: rangeVectorFunction,
    offsetExpression: offsetExpression,
  };

  local inner =
    if range == null then
      |||
        %(metric)s{%(selector)s}%(offsetExpression)s
      ||| % formatConfig
    else if aggregationLabels != null then
      |||
        %(aggregation) by (aggregationLabels) (%(rangeVectorFunction)s(%(metric)s{%(selector)s}[%(range)s]%(offsetExpression)s))
      ||| % formatConfig {
        aggregationLabels: aggregations.serialize(aggregationLabels),
        aggregation: aggregation,
      }
    else
      |||
        %(rangeVectorFunction)s(%(metric)s{%(selector)s}[%(range)s]%(offsetExpression)s)
      ||| % formatConfig;

  if clampToExpression == null then
    inner
  else
    |||
      clamp_min(
        %s,
        scalar(min(%s))
      )
    ||| % [inner, clampToExpression];

local opsRateQuery(aggregationSet, selectorHash, range=null, offset=null) =
  local metric = aggregationSet.getOpsRateMetricForBurnRate('5m');
  local selector = selectors.merge(aggregationSet.selector, selectorHash);

  local offsetExpression = if offset == null then '' else ' offset ' + offset;

  local formatConfig = {
    range: range,
    metric: metric,
    selector: selectors.serializeHash(selector),
    offsetExpression: offsetExpression,
  };

  if range == null then
    |||
      %(metric)s{%(selector)s}%(offsetExpression)s
    ||| % formatConfig
  else
    |||
      avg_over_time(%(metric)s{%(selector)s}[%(range)s]%(offsetExpression)s)
    ||| % formatConfig;

local errorRatioQuery(aggregationSet, aggregationLabels, selectorHash, range=null, clampMax=1.0, worstCase=true, offset=null, clampToExpression=null) =
  local metric = aggregationSet.getErrorRatioMetricForBurnRate('5m');
  local selector = selectors.merge(aggregationSet.selector, selectorHash);

  local aggregation = if worstCase then 'max' else 'avg';
  local rangeVectorFunction = if worstCase then 'max_over_time' else 'avg_over_time';
  local offsetExpression = if offset == null then '' else ' offset ' + offset;

  local formatConfig = {
    range: range,
    metric: metric,
    selector: selectors.serializeHash(selector),
    rangeVectorFunction: rangeVectorFunction,
    offsetExpression: offsetExpression,
  };

  local expr = if range == null then
    |||
      %(metric)s{%(selector)s}%(offsetExpression)s
    ||| % formatConfig
  else if aggregationLabels != null then
    |||
      %(aggregation) by (aggregationLabels) (%(rangeVectorFunction)s(%(metric)s{%(selector)s}[%(range)s]%(offsetExpression)s))
    ||| % formatConfig {
      aggregationLabels: aggregations.serialize(aggregationLabels),
      aggregation: aggregation,
    }
  else
    |||
      %(rangeVectorFunction)s(%(metric)s{%(selector)s}[%(range)s]%(offsetExpression)s)
    ||| % formatConfig;

  local clampMaxExpressionWithDefault =
    if clampToExpression == null then
      '' + clampMax
    else
      'scalar(max(%s))' % [clampToExpression];

  |||
    clamp_max(
      %s,
      %s
    )
  ||| % [expr, clampMaxExpressionWithDefault];

{
  apdexQuery:: apdexQuery,
  opsRateQuery:: opsRateQuery,
  errorRatioQuery:: errorRatioQuery,

  apdex:: {
    /**
     * Returns a promql query a 6h error budget SLO
     *
     * @return a string representation of the PromQL query
     */
    serviceApdexDegradationSLOQuery(type)::
      |||
        (1 - %(burnrate_6h)g * (1 - avg(slo:min:events:gitlab_service_apdex:ratio{%(selectors)s})))
      ||| % {
        selectors: selectors.serializeHash({ type: type, monitor: 'global' }),
        burnrate_6h: multiburnFactors.burnrate_6h,
      },

    serviceApdexOutageSLOQuery(type)::
      |||
        (1 - %(burnrate_1h)g * (1 - avg(slo:min:events:gitlab_service_apdex:ratio{%(selectors)s})))
      ||| % {
        selectors: selectors.serializeHash({ type: type, monitor: 'global' }),
        burnrate_1h: multiburnFactors.burnrate_1h,
      },
  },

  opsRate:: {
    serviceOpsRatePrediction(selectorHash, sigma)::
      |||
        clamp_min(
          avg by (type) (
            gitlab_service_ops:rate:prediction{%(globalSelector)s}
            + (%(sigma)g) *
            gitlab_service_ops:rate:stddev_over_time_1w{%(globalSelector)s}
          ),
          0
        )
      ||| % {
        sigma: sigma,
        globalSelector: selectors.serializeHash(selectorHash + globalSelector),
      },
  },

  errorRate:: {
    serviceErrorRateDegradationSLOQuery(type)::
      |||
        (%(burnrate_6h)g * avg(slo:max:events:gitlab_service_errors:ratio{%(selectors)s}))
      ||| % {
        selectors: selectors.serializeHash({ type: type, monitor: 'global' }),
        burnrate_6h: multiburnFactors.burnrate_6h,
      },

    serviceErrorRateOutageSLOQuery(type)::
      |||
        (%(burnrate_1h)g * avg(slo:max:events:gitlab_service_errors:ratio{%(selectors)s}))
      ||| % {
        selectors: selectors.serializeHash({ type: type, monitor: 'global' }),
        burnrate_1h: multiburnFactors.burnrate_1h,
      },
  },
}