local recordingRuleRegistry = import '../../recording-rule-registry.libsonnet';
local aggregations = import 'promql/aggregations.libsonnet';
local selectors = import 'promql/selectors.libsonnet';

{
  resolveRateQuery(metricName, selector, rangeInterval, useRecordingRuleRegistry, aggregationFunction=null, aggregationLabels=[])::
    local recordedRate = recordingRuleRegistry.resolveRecordingRuleFor(
      aggregationFunction=aggregationFunction,
      aggregationLabels=aggregationLabels,
      rangeVectorFunction='rate',
      metricName=metricName,
      rangeInterval=rangeInterval,
      selector=selector,
    );
    if useRecordingRuleRegistry && recordedRate != null then
      recordedRate
    else
      local query = 'rate(%(metric)s{%(selector)s}[%(rangeInterval)s])' % {
        metric: metricName,
        selector: selectors.serializeHash(selector),
        rangeInterval: rangeInterval,
      };

      if aggregationFunction == null then
        query
      else
        aggregations.aggregateOverQuery(aggregationFunction, aggregationLabels, query),
}
