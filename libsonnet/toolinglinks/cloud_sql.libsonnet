local toolingLinkDefinition = (import './tooling_link_definition.libsonnet').toolingLinkDefinition;
local stackdriverLogs = import './stackdriver_logs.libsonnet';

{
  cloudSQL(
    instanceId,
    project='gitlab-production',
  )::
    [
      toolingLinkDefinition({
        title: 'Cloud SQL',
        url: 'https://console.cloud.google.com/sql/instances/%(instanceId)s/overview?project=%(project)s' % {
          instanceId: instanceId,
          project: project,
        },
      }),
      stackdriverLogs.stackdriverLogsEntry(
        title='Stackdriver Logs: Cloud SQL %s' % [instanceId],
        queryHash={
          'resource.type': 'cloudsql_database',
          'resource.labels.database_id': project + ':' + instanceId,
          'resource.labels.project_id': project,
        },
        project=project
      ),
    ],
}
