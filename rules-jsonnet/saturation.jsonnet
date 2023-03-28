local saturationResources = import 'servicemetrics/saturation-resources.libsonnet';
local saturationRules = import 'servicemetrics/saturation_rules.libsonnet';

local includePrometheusEvaluated = true;
local includeDangerouslyThanosEvaluated = false;

{
  'saturation.yml':
    std.manifestYamlDoc({
      groups:
        saturationRules.generateSaturationRulesGroup(
          saturationResources=saturationResources,
          includePrometheusEvaluated=includePrometheusEvaluated,
          includeDangerouslyThanosEvaluated=includeDangerouslyThanosEvaluated,
        )
        +
        saturationRules.generateSaturationMetadataRulesGroup(
          saturationResources=saturationResources,
          includePrometheusEvaluated=includePrometheusEvaluated,
          includeDangerouslyThanosEvaluated=includeDangerouslyThanosEvaluated,
        )
        +
        // Metadata + Alerts
        saturationRules.generateSaturationAuxRulesGroup(
          saturationResources=saturationResources,
          includePrometheusEvaluated=includePrometheusEvaluated,
          includeDangerouslyThanosEvaluated=includeDangerouslyThanosEvaluated,
        ),
    }),
}
