import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      "@": import.meta.dirname,
    },
  },
  test: {
    include: ["tests/units/**/*.test.*"],
    environment: "jsdom",
    setupFiles: "./tests/vitestSetup.tsx",
  },
});
