import { expect, test } from "@playwright/test";
import enMessages from "@/messages/en.json";
import svMessages from "@/messages/sv.json";

// Test that loads the deployed application in English, checks that it loaded successfully and that the heading is visible.
test("loads the deployed application in English", async ({ page }) => {
  // Load base URL in English.
  const response = await page.goto("/en");

  // Check that the page loaded successfully.
  expect(response?.ok()).toBe(true);

  // CHeck that the heading is visible on the page.
  await expect(page.getByText(enMessages.HomePage.heading)).toBeVisible();
});

// Test that switches from English to Swedish and checks that the URL and heading is correct.
test("switches from English to Swedish", async ({ page }) => {
  // Ensure that we start on the English page.
  await page.goto("/en");

  // Click the language switcher button (currently showing English), and then click the Swedish option in the dropdown menu.
  await page.getByRole("button", { name: "English" }).click();
  await page.getByRole("menuitem", { name: "Svenska" }).click();

  // CHeck that the URL shows Swedish locale.
  await expect(page).toHaveURL(/\/sv$/);

  // Check that the heading is shown in Swedish on the page.
  await expect(page.getByRole("heading", { name: svMessages.HomePage.heading })).toBeVisible();
});
