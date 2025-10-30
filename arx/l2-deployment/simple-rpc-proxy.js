#!/usr/bin/env node

// Simple RPC proxy that forwards all calls to op-geth
// This allows op-batcher and op-proposer to work without op-node

const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const PORT = 9545;
const GETH_RPC = 'http://localhost:8545';

// Load rollup config
let rollupConfig = {};
try {
  const configPath = path.join(__dirname, 'rollup.json');
  rollupConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  console.log('✅ Loaded rollup config');
} catch (err) {
  console.error('Failed to load rollup config:', err.message);
}

const server = http.createServer(async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Content-Type', 'application/json');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  if (req.method !== 'POST') {
    res.writeHead(405);
    res.end(JSON.stringify({ error: 'Method not allowed' }));
    return;
  }

  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });

  req.on('end', async () => {
    try {
      let request = {};
      if (body) {
        request = JSON.parse(body);
      }
      
      console.log(`RPC Call: ${request.method}`);
      
      // Handle optimism-specific RPC methods
      if (request.method === 'optimism_rollupConfig') {
        console.log('Handling optimism_rollupConfig');
        // Create properly formatted config for op-batcher/op-proposer
        const config = {
          genesis: {
            l1: rollupConfig.genesis?.l1 || {},
            l2: rollupConfig.genesis?.l2 || {},
            l2Time: rollupConfig.genesis?.l2_time !== undefined ? rollupConfig.genesis.l2_time : 0,
            systemConfig: rollupConfig.genesis?.system_config || {}
          },
          l1ChainID: rollupConfig.l1_chain_id,
          l2ChainID: rollupConfig.l2_chain_id,
          blockTime: rollupConfig.block_time,
          maxSequencerDrift: rollupConfig.max_sequencer_drift,
          seqWindowSize: rollupConfig.seq_window_size,
          channelTimeout: rollupConfig.channel_timeout,
          batchInboxAddress: rollupConfig.batch_inbox_address,
          depositContractAddress: rollupConfig.deposit_contract_address,
          l1SystemConfigAddress: rollupConfig.l1_system_config_address,
          regolithTime: rollupConfig.regolith_time,
          canyonTime: rollupConfig.canyon_time,
          deltaTime: rollupConfig.delta_time,
          ecotoneTime: rollupConfig.ecotone_time,
          fjordTime: rollupConfig.fjord_time
        };
        
        console.log('Sending config with genesis.l2Time:', config.genesis.l2Time);
        
        res.writeHead(200);
        res.end(JSON.stringify({
          jsonrpc: '2.0',
          id: request.id,
          result: config
        }));
        return;
      }
      
      // Forward everything else to op-geth
      const options = new URL(GETH_RPC);
      options.method = 'POST';
      options.headers = {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body)
      };

      const proxyReq = http.request(options, (proxyRes) => {
        let responseData = '';
        proxyRes.on('data', chunk => {
          responseData += chunk;
        });
        proxyRes.on('end', () => {
          res.writeHead(proxyRes.statusCode, proxyRes.headers);
          res.end(responseData);
        });
      });

      proxyReq.on('error', (err) => {
        console.error('Proxy error:', err);
        res.writeHead(502);
        res.end(JSON.stringify({ error: 'Bad gateway', details: err.message }));
      });

      proxyReq.write(body);
      proxyReq.end();
    } catch (err) {
      console.error('Error:', err);
      res.writeHead(500);
      res.end(JSON.stringify({ error: 'Internal server error' }));
    }
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ RPC Proxy listening on http://0.0.0.0:${PORT}`);
  console.log(`   Forwarding to: ${GETH_RPC}`);
});

server.on('error', (err) => {
  console.error('Server error:', err);
  process.exit(1);
});
