local layout = import 'layout.libsonnet';
local basic = import 'basic.libsonnet';

{
  namedGroup(title, groupname, serviceType, serviceStage, startRow)::
    layout.grid([
      basic.timeseries(
      title="Process CPU Time",
      description="Seconds of CPU time for the named process group, per second",
      query='
        sum(
          rate(
            namedprocess_namegroup_cpu_seconds_total{
              environment="$environment",
              groupname="' + groupname + '",
              type="' + serviceType + '",
              stage="' + serviceStage + '"
            }[$__interval]
          )
        ) without (mode)
      ',
      legendFormat='{{ fqdn }}',
      interval="1m",
      intervalFactor=1,
      format='s',
      legend_show=false,
      linewidth=1
    ),
    basic.timeseries(
      title=title + ": Open File Descriptors",
      description="Maximum number of open file descriptors per host",
      query='
        max(
            namedprocess_namegroup_open_filedesc{
              environment="$environment",
              groupname="' + groupname + '",
              type="' + serviceType + '",
              stage="' + serviceStage + '"
            }
        ) by (fqdn)
      ',
      legendFormat='{{ fqdn }}',
      interval="1m",
      intervalFactor=1,
      legend_show=false,
      linewidth=1
    ),
    basic.timeseries(
      title=title + ": Number of Threads",
      description="Number of threads in the process group",
      query='
        sum(
            namedprocess_namegroup_num_threads{
              environment="$environment",
              groupname="' + groupname + '",
              type="' + serviceType + '",
              stage="' + serviceStage + '"
            }
        ) by (fqdn)
      ',
      legendFormat='{{ fqdn }}',
      interval="1m",
      intervalFactor=1,
      legend_show=false,
      linewidth=1
    ),
    basic.timeseries(
      title=title + ": Memory Usage",
      description="Memory usage for named process group",
      query='
        sum(
            namedprocess_namegroup_memory_bytes{
              environment="$environment",
              groupname="' + groupname + '",
              type="' + serviceType + '",
              stage="' + serviceStage + '"
            }
        ) by (fqdn)
      ',
      legendFormat='{{ fqdn }}',
      interval="1m",
      format='bytes',
      intervalFactor=1,
      legend_show=false,
      linewidth=1
    ),

    ], startRow=startRow)


}
