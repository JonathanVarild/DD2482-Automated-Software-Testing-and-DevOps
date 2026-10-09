import { afterAll, beforeEach, expect, it } from "vitest";

import { pool } from "@/lib/database";
import { registerUser } from "@/server/services/authenticationService";

// Create an arbitrary user that we should try creating.
const user = {
  name: "Test",
  surname: "Test",
  pnr: "20000101-0001",
  email: "test@test.com",
  password: "Qwerty123!",
  username: "test",
};

// REmove logs related to the user and lastly the user itself from the database.
async function cleanupTestUser() {
  await pool.query("DELETE FROM log WHERE actor_person_id IN (SELECT person_id FROM person WHERE username = $1)", [user.username]);
  await pool.query("DELETE FROM person WHERE username = $1", [user.username]);
}

// Ensure that the user doesn't exist before a test starts.
beforeEach(cleanupTestUser);

// Clean up and close database connections once we are done.
afterAll(async () => {
  await cleanupTestUser();
  await pool.end();
});

// Test that we can register a user and verify that its stored in the database.
it("registers a test user and stores their session", async () => {
  // Register the user with authentication service function.
  const result = await registerUser(user, new Request("http://localhost/api/signup"));

  // Interface database directly to verify that the user exists.
  const insertedUser = await pool.query(
    `SELECT username
     FROM person
     WHERE person_id = $1`,
    [result.userID],
  );

  // Check so that we received a single suer and that the username matches the user we just created.
  expect(insertedUser.rows).toHaveLength(1);
  expect(insertedUser.rows[0].username).toBe(user.username);
});
