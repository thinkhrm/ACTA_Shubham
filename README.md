# ACTA - Automated Compliance Tracking Application

A comprehensive React-based compliance management system built with TypeScript, Vite, and Supabase.

## Features

- **Multi-role Authentication**: Admin, Entity User, and Super Admin roles
- **Compliance Management**: Track and manage compliance requirements
- **Document Management**: Upload and organize compliance documents
- **Branch Management**: Multi-branch support for organizations
- **License Tracking**: Monitor license renewals and expirations
- **Contractor Management**: Manage contractor compliance
- **Government Communications**: Track official communications
- **Escalation System**: Automated escalation for compliance issues

## Testing Tools

This application includes built-in testing tools for authentication:

### Login Troubleshooter
Located in `src/components/Auth/LoginTroubleshooter.tsx`
- Test login with custom credentials
- Diagnose authentication issues
- Automatically create user records if missing
- Display detailed error messages and user data

### Quick Login Test
Located in `src/components/Auth/QuickLoginTest.tsx`
- Test with predefined credentials for different roles:
  - **Admin**: admin@acta.com / admin123
  - **Entity User**: entity@acta.com / entity123
  - **Super Admin**: super@acta.com / super123
- Batch test all login scenarios
- Automatic sign-out between tests

## Project Structure

```
src/
├── components/          # React components organized by feature
│   ├── Auth/           # Authentication components
│   ├── Dashboard/      # Dashboard components
│   ├── Compliance/     # Compliance management
│   ├── Documents/      # Document management
│   ├── Branches/       # Branch management
│   └── ...
├── contexts/           # React contexts for state management
├── services/           # API service functions
├── types/              # TypeScript type definitions
├── utils/              # Utility functions
└── lib/                # External library configurations
```

## Setup Instructions

1. Copy `.env.example` to `.env`
2. Fill in your Supabase credentials
3. Run `npm install` to install dependencies
4. Run `npm run dev` to start the development server

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build

## Technologies Used

- React 18 with TypeScript
- Vite for build tooling
- Tailwind CSS for styling
- Supabase for backend and authentication
- Lucide React for icons
- React Router for navigation"# ACTA_Shubham" 
"# ACTA_Shubham" 
