import { createApp } from "./app";
import { config } from "./config";

const app = createApp();

app.listen(config.PORT, () => {
  console.log(`nepal-heritage-api listening on http://127.0.0.1:${config.PORT}`);
});
