import { expect, test } from "@playwright/test";

// Test to check that the login backend API is reachable, and that it is behaving
// as expected, indicating that the backend has a valid connection to the database.
test("rejects invalid login credentials", async ({ request }) => {
  // Send a request to the login API with obviously invalid login credentials.
  const response = await request.post("/api/login", {
    data: {
      username: `nonexistent-e2e-user-${Date.now()}`,
      password: "InvalidPassword1",
    },
  });

  // Check that the API responds with 401 (unauthorized).
  expect(response.status()).toBe(401);

  // Check that the response contains the correct translation key.
  expect(await response.json()).toMatchObject({
    translationKey: "invalidCredentialsError",
  });
});

// Test to check that the registration backend API is reachable, and that it is rejecting invalid registration data.
test("rejects invalid registration data", async ({ request }) => {
  // Send a request to the registration API with obviously invalid registration data.
  const response = await request.post("/api/signup", { data: {} });

  // Check that the API responds with 400 (bad request).
  expect(response.status()).toBe(400);

  // Check that the response contains the correct translation key.
  expect(await response.json()).toMatchObject({
    translationKey: "invalidFormDataError",
  });
});
