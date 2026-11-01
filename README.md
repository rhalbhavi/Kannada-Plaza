<div align="center">

  # Kannada Plaza
  ## Learn Everyday Kannada Phrases by Exploring a Fun and Interactive City.

</div>

## Running locally

Install Flutter 3.41.6 or newer, then run:

```sh
flutter pub get
flutter run -d chrome
```

## Deploying to Vercel

The GitHub Actions workflow builds the Flutter web app on pushes to `main`.
To enable its production deployment step, configure these repository secrets
under **Settings → Secrets and variables → Actions**:

- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

The workflow links the Vercel project, builds the static site, and deploys
`build/web` to production. Vercel's SPA rewrite configuration is in
[`vercel.json`](./vercel.json).
