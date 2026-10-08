import { expect, it } from "vitest";
import { POST } from "@/app/api/signup/route";

// Test that a signup request with invalid form data is rejected with HTTP 400 (bad request).
it("rejects an invalid signup request", async () => {
  // Interface the signup route directly with an empty request body to simulate invalid form data.
  const response = await POST(
    new Request("http://localhost/api/signup", {
      method: "POST",
      body: JSON.stringify({}),
    }),
  );

  // Check that the response is HTTP 400 (bad request), that the error message is correct, and that the translation key is correct.
  expect(response.status).toBe(400);
  expect(await response.json()).toEqual({
    error: "The provided form data is invalid.",
    translationKey: "invalidFormDataError",
  });
});
