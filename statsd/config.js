{
  port: 8125,
  mgmt_port: 8126,

  percentThreshold: [ 50, 75, 90, 95, 98, 99, 99.9, 99.99, 99.999],

  graphitePort: 2003,
  graphiteHost: "127.0.0.1",
  flushInterval: 10000,

  debug: true,

  backends: ['./backends/graphite', './influxdb'],
  graphite: {
    legacyNamespace: false
  },
  influxdb: {
    host: '127.0.0.1',   // InfluxDB host. (default 127.0.0.1)
    port: 8086,          // InfluxDB port. (default 8086)
    database: 'statsd',  // InfluxDB database instance. (required)
    username: 'root',    // InfluxDB database username. (required)
    password: 'root',    // InfluxDB database password. (required)
    flush: {
      enable: true       // Enable regular flush strategy. (default true)
    },
    proxy: {
      enable: true,       // Enable the proxy strategy. (default false)
      suffix: 'raw',       // Metric name suffix. (default 'raw')
      flushInterval: 1000  // Flush interval for the internal buffer.
                           // (default 1000)
    }
  }
}
