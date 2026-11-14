# Vigor Broad admin account setup

The admin page authenticates with Supabase Auth and grants catalogue access only to a user whose protected `app_metadata.role` is `admin`. The seven-tap logo shortcut is navigation only; it is not an access control.

## 1. Create or invite the administrator

In the VigorBroad project, add the chosen administrator from **Authentication → Users**. Keep public sign-ups disabled unless the product owner has approved them.

## 2. Assign the admin claim from a trusted server

The Admin API requires a server-only secret/service-role key. Never put that key in `admin.html`, another browser file, or a public repository.

Run a short-lived server-side script using the pinned Supabase JavaScript client version already used by this project. Supply the project URL, secret key, and the Auth user ID through environment variables. Fetch the user with `auth.admin.getUserById(userId)`, preserve the existing app metadata, then call:

```js
await supabase.auth.admin.updateUserById(userId, {
  app_metadata: { ...user.app_metadata, role: "admin" }
});
```

Use the trusted Admin API only. Do not assign the role through `user_metadata`, because users can change that field themselves.

## 3. Refresh the administrator session

Sign out of Vigor Admin and sign in again. Supabase places the updated app metadata in the refreshed access token, which the database policies check.

## Access model

- Anonymous visitors can read active sectors and published developments.
- Only authenticated users with `app_metadata.role = admin` can read drafts or change catalogue records.
- Development changes are recorded in the private audit log.
- The Supabase service-role/secret key must remain on a trusted server and must never be added to this repository.
