module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "198.13.60.39",
      port: 8545,
      network_id: "*" // Match any network id
    },
    test: {
        host: "127.0.0.1",
        port: 7545,
        network_id: 5777 // Match any network id
    }
  }
};