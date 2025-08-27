Environment setup
-----------------

Create a `.env` file in this directory with the following variables (copy from this template):

```
AZURE_ENDPOINT=https://<your-cognitive-services>.cognitiveservices.azure.com/
AZURE_API_VERSION=2025-05-01-preview
AZURE_SUBSCRIPTION_KEY=
# AZURE_CONTENT_UNDERSTANDING_AAD_TOKEN=
AZURE_ANALYZER_ID=Extract-Table
FILE_LOCATION=./Data/utp-test-2.pdf
```

Do not commit `.env`. Ensure your repo ignores it, e.g. add this to your `.gitignore`:

```
backend/.env
```

Install dependencies
--------------------

Use your preferred tool (e.g. uv/pip/poetry) to install:

```
requests>=2.32.0
python-dotenv>=1.0.1
```


### COLORS 
CIENCIAS Y TECNOLOGÍA #ff7e00
INGENIERÍA CIVIL #610563
INGENIERÍA ELÉCTRICA #0090d9
INGENIERÍA INDUSTRIAL #1b65a2
INGENIERÍA MECÁNICA #90244f
INGENIERÍA DE SISTEMAS COMPUTACIONALES #237c2c

# 🚀 Potential Improvements:
1. Progress Tracking & Analytics
Progress percentage - Show overall completion percentage
Semester progress - Track progress by semester/year
GPA calculation - If we add grade tracking
Time to graduation estimate - Based on current pace
2. Enhanced Course Management
Bulk actions - Mark multiple courses as passed/failed at once
Course search/filter - Filter by semester, requirements, etc.
Course notes - Allow users to add personal notes to courses
Grade tracking - Add actual grades (A, B, C, etc.) instead of just pass/fail
3. Better Visual Feedback
Progress bars - Visual progress indicators
Course dependency graph - Visual representation of prerequisites
Semester timeline - Visual timeline of courses
Achievement badges - For completing milestones
4. Export & Sharing
Export to PDF - Generate progress reports
Share progress - Share with advisors
Backup/restore - Export/import study plans
5. Smart Features
Course recommendations - Suggest optimal course sequences
Conflict detection - Warn about scheduling conflicts
Graduation requirements checker - Verify all requirements are met
6. UI/UX Enhancements
Keyboard shortcuts - For power users
Dark/light theme toggle
Responsive improvements - Better mobile experience
Animations - Smooth transitions and micro-interactions
Would you like me to implement any of these features? I'd recommend starting with:
Progress percentage - Simple but impactful
Course search/filter - Improves usability with large plans
Bulk actions - Saves time for users
Which improvement interests you most?