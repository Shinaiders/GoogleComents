import { createClient } from "redis";
import * as dotenv from "dotenv";
dotenv.config();

const redisserver = process.env.REDIS

export const client = createClient({
  url: redisserver,
});

client.connect();
