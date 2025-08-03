import { registerAs } from '@nestjs/config';

export const ollamaConfig = registerAs('ollama', () => ({
  host: process.env.OLLAMA_HOST || 'localhost',
  port: parseInt(process.env.OLLAMA_PORT, 10) || 11434,
  model: process.env.OLLAMA_MODEL || 'phi3:mini',
  timeout: parseInt(process.env.OLLAMA_TIMEOUT, 10) || 300000,
  temperature: parseFloat(process.env.OLLAMA_TEMPERATURE) || 0.7,
  topP: parseFloat(process.env.OLLAMA_TOP_P) || 0.9,
  maxTokens: parseInt(process.env.OLLAMA_MAX_TOKENS, 10) || 1000,
})); 