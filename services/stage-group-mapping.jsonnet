// This file is autogenerated using scripts/update-stage-groups-feature-categories
// Please don't update manually
{
  access: {
    name: 'Access',
    stage: 'manage',
    feature_categories: [
      'authentication_and_authorization',
      'subgroups',
      'users',
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
      'templates',
    ],
  },
  optimize: {
    name: 'Optimize',
    stage: 'manage',
    feature_categories: [
      'devops_reports',
      'planning_analytics',
      'code_analytics',
      'value_stream_management',
      'insights',
    ],
  },
  project_management: {
    name: 'Project Management',
    stage: 'plan',
    feature_categories: [
      'issue_tracking',
      'boards',
      'time_tracking',
      'jira_importer',
      'projects',
    ],
  },
  product_planning: {
    name: 'Product Planning',
    stage: 'plan',
    feature_categories: [
      'epics',
      'roadmaps',
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
  knowledge: {
    name: 'Knowledge',
    stage: 'create',
    feature_categories: [
      'design_management',
      'design_system',
      'wiki',
    ],
  },
  static_site_editor: {
    name: 'Static Site Editor',
    stage: 'create',
    feature_categories: [
      'static_site_editor',
      'gitlab_handbook',
      'gitlab_docs',
      'navigation',
    ],
  },
  editor: {
    name: 'Editor',
    stage: 'create',
    feature_categories: [
      'web_ide',
      'snippets',
      'live_preview',
    ],
  },
  gitaly: {
    name: 'Gitaly',
    stage: 'create',
    feature_categories: [
      'gitaly',
    ],
  },
  ecosystem: {
    name: 'Ecosystem',
    stage: 'create',
    feature_categories: [
      'api',
      'integrations',
      'gdk',
      'foundations',
    ],
  },
  continuous_integration: {
    name: 'Continuous Integration',
    stage: 'verify',
    feature_categories: [
      'continuous_integration',
      'merge_trains',
      'jenkins_importer',
    ],
  },
  pipeline_authoring: {
    name: 'Pipeline Authoring',
    stage: 'verify',
    feature_categories: [
      'pipeline_authoring',
    ],
  },
  runner: {
    name: 'Runner',
    stage: 'verify',
    feature_categories: [
      'runner',
    ],
  },
  testing: {
    name: 'Testing',
    stage: 'verify',
    feature_categories: [
      'code_quality',
      'code_testing',
      'load_testing',
      'web_performance',
      'usability_testing',
      'accessibility_testing',
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
      'jupyter_notebooks',
      'git_lfs',
    ],
  },
  static_analysis: {
    name: 'Static Analysis',
    stage: 'secure',
    feature_categories: [
      'static_application_security_testing',
      'secret_detection',
      'malware_scanning',
    ],
  },
  dynamic_analysis: {
    name: 'Dynamic Analysis',
    stage: 'secure',
    feature_categories: [
      'dynamic_application_security_testing',
      'pki_management',
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
  fuzz_testing: {
    name: 'Fuzz Testing',
    stage: 'secure',
    feature_categories: [
      'fuzz_testing',
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
      'review_apps',
      'feature_flags',
      'release_orchestration',
      'secrets_management',
      'release_evidence',
      'pages',
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
      'serverless',
      'chatops',
      'runbooks',
    ],
  },
  monitor: {
    name: 'Monitor',
    stage: 'monitor',
    feature_categories: [
      'error_tracking',
      'incident_management',
      'metrics',
      'tracing',
      'logging',
      'synthetic_monitoring',
      'self_monitoring',
    ],
  },
  container_security: {
    name: 'Container Security',
    stage: 'protect',
    feature_categories: [
      'web_firewall',
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
  activation: {
    name: 'Activation',
    stage: 'growth',
    feature_categories: null,
  },
  conversion: {
    name: 'Conversion',
    stage: 'growth',
    feature_categories: null,
  },
  expansion: {
    name: 'Expansion',
    stage: 'growth',
    feature_categories: null,
  },
  adoption: {
    name: 'Adoption',
    stage: 'growth',
    feature_categories: null,
  },
  product_analytics: {
    name: 'Product Analytics',
    stage: 'growth',
    feature_categories: [
      'collection',
      'analysis',
      'product_analytics',
    ],
  },
  distribution: {
    name: 'Distribution',
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
  infrastructure: {
    name: 'Infrastructure',
    stage: 'enablement',
    feature_categories: [
      'infrastructure',
    ],
  },
  'ML/AI': {
    name: 'Machine Learning',
    stage: 'learn',
    feature_categories: [
      'mlops',
      'insider_threat',
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
