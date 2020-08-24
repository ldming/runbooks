local toolingLinkDefinition = (import './tooling_link_definition.libsonnet').toolingLinkDefinition;

{
  elasticAPM(service)::
    [
      toolingLinkDefinition({
        title: 'Elastic APM: ' + service,
        url: 'https://log.gprd.gitlab.net/app/apm#/services/%(service)s/transactions' % {
          service: service,
        },
      }),
    ],
}
