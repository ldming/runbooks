// This file is autogenerated using scripts/update_stage_groups_feature_categories.rb
// Please don't update manually
{
  authentication_and_authorization: {
    name: 'Authentication & Authorization',
    stage: 'manage',
    feature_categories: [
      'authentication_and_authorization',
      'permissions',
      'user_management',
      'credential_management',
      'system_access',
    ],
  },
  workspace: {
    name: 'Workspace',
    stage: 'manage',
    feature_categories: [
      'subgroups',
      'users',
      'projects',
    ],
  },
  compliance: {
    name: 'Compliance',
    stage: 'manage',
    feature_categories: [
      'audit_events',
      'audit_reports',
      'compliance_management',
    ],
  },
  'import': {
    name: 'Import',
    stage: 'manage',
    feature_categories: [
      'importers',
      'internationalization',
    ],
  },
  optimize: {
    name: 'Optimize',
    stage: 'manage',
    feature_categories: [
      'devops_reports',
      'value_stream_management',
    ],
  },
  project_management: {
    name: 'Project Management',
    stage: 'plan',
    feature_categories: [
      'team_planning',
      'planning_analytics',
    ],
  },
  product_planning: {
    name: 'Product Planning',
    stage: 'plan',
    feature_categories: [
      'portfolio_management',
      'design_management',
    ],
  },
  certify: {
    name: 'Certify',
    stage: 'plan',
    feature_categories: [
      'requirements_management',
      'quality_management',
      'service_desk',
    ],
  },
  source_code: {
    name: 'Source Code',
    stage: 'create',
    feature_categories: [
      'source_code_management',
    ],
  },
  code_review: {
    name: 'Code Review',
    stage: 'create',
    feature_categories: [
      'code_review',
      'editor_extension',
    ],
  },
  editor: {
    name: 'Editor',
    stage: 'create',
    feature_categories: [
      'web_ide',
      'snippets',
      'wiki',
      'static_site_editor',
      'pages',
    ],
  },
  gitaly: {
    name: 'Gitaly',
    stage: 'create',
    feature_categories: [
      'gitaly',
    ],
  },
  integrations: {
    name: 'Integrations',
    stage: 'ecosystem',
    feature_categories: [
      'integrations',
    ],
  },
  foundations: {
    name: 'Foundations',
    stage: 'ecosystem',
    feature_categories: [
      'design_system',
      'navigation',
      'gitlab_docs',
    ],
  },
  pipeline_execution: {
    name: 'Pipeline Execution',
    stage: 'verify',
    feature_categories: [
      'continuous_integration',
      'merge_trains',
      'continuous_integration_scaling',
    ],
  },
  pipeline_authoring: {
    name: 'Pipeline Authoring',
    stage: 'verify',
    feature_categories: [
      'pipeline_authoring',
      'jenkins_importer',
      'secrets_management',
    ],
  },
  runner: {
    name: 'Runner',
    stage: 'verify',
    feature_categories: [
      'runner',
      'runner_saas',
      'runner_fleet',
    ],
  },
  pipeline_insights: {
    name: 'Pipeline Insights',
    stage: 'verify',
    feature_categories: [
      'code_testing',
      'performance_testing',
      'build_artifacts',
      'review_apps',
    ],
  },
  package: {
    name: 'Package',
    stage: 'package',
    feature_categories: [
      'container_registry',
      'package_registry',
      'helm_chart_registry',
      'dependency_proxy',
      'dependency_firewall',
      'git_lfs',
    ],
  },
  static_analysis: {
    name: 'Static Analysis',
    stage: 'secure',
    feature_categories: [
      'static_application_security_testing',
      'secret_detection',
      'code_quality',
    ],
  },
  dynamic_analysis: {
    name: 'Dynamic Analysis',
    stage: 'secure',
    feature_categories: [
      'dynamic_application_security_testing',
      'fuzz_testing',
      'api_security',
      'interactive_application_security_testing',
      'attack_emulation',
    ],
  },
  composition_analysis: {
    name: 'Composition Analysis',
    stage: 'secure',
    feature_categories: [
      'dependency_scanning',
      'license_compliance',
    ],
  },
  threat_insights: {
    name: 'Threat Insights',
    stage: 'secure',
    feature_categories: [
      'vulnerability_management',
    ],
  },
  vulnerability_research: {
    name: 'Vulnerability Research',
    stage: 'secure',
    feature_categories: [
      'vulnerability_database',
      'security_benchmarking',
    ],
  },
  release: {
    name: 'Release',
    stage: 'release',
    feature_categories: [
      'continuous_delivery',
      'advanced_deployments',
      'feature_flags',
      'release_orchestration',
      'release_evidence',
      'environment_management',
    ],
  },
  configure: {
    name: 'Configure',
    stage: 'configure',
    feature_categories: [
      'auto_devops',
      'infrastructure_as_code',
      'kubernetes_management',
      'cluster_cost_management',
      'chatops',
      'deployment_management',
    ],
  },
  respond: {
    name: 'Respond',
    stage: 'monitor',
    feature_categories: [
      'incident_management',
      'on_call_schedule_management',
      'runbooks',
      'continuous_verification',
    ],
  },
  observability: {
    name: 'Observability',
    stage: 'monitor',
    feature_categories: [
      'metrics',
      'tracing',
      'logging',
      'error_tracking',
    ],
  },
  container_security: {
    name: 'Container Security',
    stage: 'protect',
    feature_categories: [
      'security_orchestration',
      'container_network_security',
      'container_host_security',
      'container_scanning',
    ],
  },
  purchase: {
    name: 'Purchase',
    stage: 'fulfillment',
    feature_categories: [
      'purchase',
    ],
  },
  provision: {
    name: 'Provision',
    stage: 'fulfillment',
    feature_categories: [
      'provision',
    ],
  },
  utilization: {
    name: 'Utilization',
    stage: 'fulfillment',
    feature_categories: [
      'utilization',
    ],
  },
  fulfillment_platform: {
    name: 'Fulfillment Platform',
    stage: 'fulfillment',
    feature_categories: [
      'fulfillment_platform',
    ],
  },
  activation: {
    name: 'Activation',
    stage: 'growth',
    feature_categories: [
      'experimentation_activation',
      'onboarding',
    ],
  },
  conversion: {
    name: 'Conversion',
    stage: 'growth',
    feature_categories: [
      'experimentation_conversion',
    ],
  },
  expansion: {
    name: 'Expansion',
    stage: 'growth',
    feature_categories: [
      'experimentation_expansion',
    ],
  },
  adoption: {
    name: 'Adoption',
    stage: 'growth',
    feature_categories: [
      'experimentation_adoption',
    ],
  },
  product_intelligence: {
    name: 'Product Intelligence',
    stage: 'growth',
    feature_categories: [
      'product_analytics',
      'service_ping',
      'privacy_control_center',
    ],
  },
  distribution_build: {
    name: 'Distribution:Build',
    stage: 'enablement',
    feature_categories: [
      'build',
    ],
  },
  distribution_deploy: {
    name: 'Distribution:Deploy',
    stage: 'enablement',
    feature_categories: [
      'omnibus_package',
      'cloud_native_installation',
    ],
  },
  geo: {
    name: 'Geo',
    stage: 'enablement',
    feature_categories: [
      'geo_replication',
      'disaster_recovery',
      'backup_restore',
    ],
  },
  memory: {
    name: 'Memory',
    stage: 'enablement',
    feature_categories: [
      'memory',
      'redis',
    ],
  },
  global_search: {
    name: 'Global Search',
    stage: 'enablement',
    feature_categories: [
      'global_search',
    ],
  },
  database: {
    name: 'Database',
    stage: 'enablement',
    feature_categories: [
      'database',
    ],
  },
  sharding: {
    name: 'Sharding',
    stage: 'enablement',
    feature_categories: [
      'sharding',
    ],
  },
  delivery: {
    name: 'Delivery',
    stage: 'platforms',
    feature_categories: [
      'delivery',
    ],
  },
  scalability: {
    name: 'Scalability',
    stage: 'platforms',
    feature_categories: [
      'scalability',
      'error_budgets',
    ],
  },
  horse: {
    name: 'Project Horse',
    stage: 'platforms',
    feature_categories: [
      'horse',
    ],
  },
  applied_ml: {
    name: 'Applied Machine Learning',
    stage: 'ModelOps',
    feature_categories: [
      'workflow_automation',
      'intel_code_security',
    ],
  },
  anti_abuse: {
    name: 'Anti-Abuse',
    stage: 'ModelOps',
    feature_categories: [
      'instance_resiliency',
      'insider_threat',
    ],
  },
  mlops: {
    name: 'MLOps',
    stage: 'ModelOps',
    feature_categories: [
      'mlops',
    ],
  },
  dataops: {
    name: 'DataOps',
    stage: 'ModelOps',
    feature_categories: [
      'dataops',
    ],
  },
  moble_devops: {
    name: 'DevOps for Mobile Apps',
    stage: 'mobile',
    feature_categories: [
      'mobile_signing_deployment',
    ],
  },
  '5-min-app': {
    name: 'Five Minute Production App',
    stage: 'deploy',
    feature_categories: [
      'five_minute_production_app',
    ],
  },
}
