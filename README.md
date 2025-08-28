# Mi Trayectoria UTP

A comprehensive web application for managing UTP (Universidad Tecnológica de Panamá) study plans and academic progress tracking.

## Features

- 📄 **PDF Upload & Processing**: Upload and automatically extract information from UTP study plan PDFs
- 📊 **Study Plan Visualization**: Interactive display of courses with prerequisites and semester organization
- ✅ **Course Status Tracking**: Mark completed courses and track academic progress
- 🎨 **Modern UI**: Clean, responsive interface with faculty-specific color themes
- 🔄 **Real-time Updates**: Automatic updates when processing documents

## About UTP

This application is specifically designed for **Universidad Tecnológica de Panamá (UTP)** students to manage their study plans and track academic progress. The system supports the following faculties:

- **CIENCIAS Y TECNOLOGÍA** (Science and Technology)
- **INGENIERÍA CIVIL** (Civil Engineering)
- **INGENIERÍA ELÉCTRICA** (Electrical Engineering)
- **INGENIERÍA INDUSTRIAL** (Industrial Engineering)
- **INGENIERÍA MECÁNICA** (Mechanical Engineering)
- **INGENIERÍA DE SISTEMAS COMPUTACIONALES** (Computer Systems Engineering)

## 🛠️ Technology Stack

### Backend Technologies

[![Python](https://img.shields.io/badge/Python-3.13+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)
[![Azure](https://img.shields.io/badge/Azure_Cognitive_Services-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![uv](https://img.shields.io/badge/uv-FFD43B?style=for-the-badge&logo=uv&logoColor=black)](https://docs.astral.sh/uv)

### Frontend Technologies

[![React](https://img.shields.io/badge/React-18.2.0-61DAFB?style=for-the-badge&logo=react&logoColor=white)](https://reactjs.org)
[![Vite](https://img.shields.io/badge/Vite-5.4.0-646CFF?style=for-the-badge&logo=vite&logoColor=white)](https://vitejs.dev)
[![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![CSS3](https://img.shields.io/badge/CSS3-Custom-1572B6?style=for-the-badge&logo=css3&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/CSS)
[![Axios](https://img.shields.io/badge/Axios-1.7.7-5A29E4?style=for-the-badge&logo=axios&logoColor=white)](https://axios-http.com)

### Development Tools

[![pnpm](https://img.shields.io/badge/pnpm-9.12.0-F69220?style=for-the-badge&logo=pnpm&logoColor=white)](https://pnpm.io)
[![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com)
[![VSCode](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com)

## 🏗️ System Architecture

```mermaid
graph TB
    A[🌐 Mi Trayectoria UTP<br/>Universidad Tecnológica de Panamá] --> B[Frontend Layer<br/>React + Vite]
    A --> C[Backend Layer<br/>FastAPI + Python]

    B --> D[User Interface]
    B --> E[Client Components]
    B --> F[Data Flow]

    C --> G[API Layer]
    C --> H[Business Logic]
    C --> I[Data Persistence]

    D --> J[PDF Upload]
    D --> K[Study Plan Viewer]
    D --> L[Course Selector]
    D --> M[Progress Tracking]

    E --> N[UploadPDF.jsx]
    E --> O[StudyPlanViewer.jsx]
    E --> P[CourseSelector.jsx]
    E --> Q[DocControls.jsx]

    F --> R[Axios HTTP]
    F --> S[Real-time Updates]
    F --> T[State Management]

    G --> U[RESTful Endpoints]
    G --> V[Data Processing]
    G --> W[Document Storage]
    G --> X[Azure AI Services]

    H --> Y[PDF Extraction]
    H --> Z[Data Cleaning]
    H --> AA[Database Ops]
    H --> BB[Faculty Mapping]

    I --> CC[SQLite Database]
    I --> DD[File Storage]
    I --> EE[Session Handling]

    X --> FF[Azure Cognitive Services]
    X --> GG[PDF Processing]
    X --> HH[AI Document Understanding]

    FF --> II[External Services]
    GG --> II
    HH --> II
```

### Architecture Components

#### 🎨 Frontend Layer (React + Vite)

- **Modern UI Components**: Interactive study plan visualization with faculty-specific theming
- **PDF Upload Interface**: Drag-and-drop file upload with progress tracking
- **Real-time Updates**: Dynamic course status updates and progress tracking
- **Responsive Design**: Mobile-friendly interface with custom CSS styling

#### ⚙️ Backend Layer (FastAPI + Python)

- **API Endpoints**: RESTful API for document processing and data management
- **PDF Processing**: Azure Cognitive Services integration for document understanding
- **Data Processing**: Intelligent extraction and cleaning of study plan data
- **Database Management**: SQLite for efficient data storage and retrieval

#### 🔗 Data Flow Architecture

- **Upload → Process → Extract → Store → Display**
- **PDF files** are uploaded via frontend, processed by Azure AI, cleaned and structured by backend, stored in database, and displayed in interactive UI

#### 🛡️ Security & Performance

- **Environment Variables**: Sensitive configuration stored securely
- **File Validation**: Proper validation of uploaded PDF files
- **Error Handling**: Comprehensive error handling and user feedback
- **Optimized Dependencies**: Efficient package management with uv and pnpm

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            🌐 Mi Trayectoria UTP                             │
│                          Universidad Tecnológica de Panamá                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                          ┌───────────┼───────────┐
                          │           │           │
               ┌──────────▼──────────┐┌──────────▼──────────┐
               │    Frontend Layer   ││   Backend Layer     │
               │   (React + Vite)    ││  (FastAPI + Python) │
               └──────────┬──────────┘└──────────┬──────────┘
                          │           │           │
                          │           │           │
               ┌──────────▼──────────┐┌──────────▼──────────┐
               │   User Interface    ││    API Layer        │
               │                     ││                     │
               │ • PDF Upload        ││ • RESTful Endpoints │
               │ • Study Plan Viewer ││ • Data Processing   │
               │ • Course Selector   ││ • Document Storage  │
               │ • Progress Tracking ││ • Azure AI Services │
               └──────────┬──────────┘└──────────┬──────────┘
                          │           │           │
                          │           │           │
               ┌──────────▼──────────┐┌──────────▼──────────┐
               │  Client Components  ││   Business Logic    │
               │                     ││                     │
               │ • UploadPDF.jsx     ││ • PDF Extraction    │
               │ • StudyPlanViewer.jsx││ • Data Cleaning    │
               │ • CourseSelector.jsx││ • Database Ops      │
               │ • DocControls.jsx   ││ • Faculty Mapping   │
               └──────────┬──────────┘└──────────┬──────────┘
                          │           │           │
                          │           │           │
               ┌──────────▼──────────┐┌──────────▼──────────┐
               │   Data Flow         ││   Data Persistence  │
               │                     ││                     │
               │ • Axios HTTP        ││ • SQLite Database   │
               │ • Real-time Updates ││ • File Storage      │
               │ • State Management  ││ • Session Handling  │
               └─────────────────────┘└─────────────────────┘
                                        │
                          ┌───────────┼───────────┐
                          │           │           │
               ┌──────────▼──────────┐┌──────────▼──────────┐
               │   External Services ││   Development Tools │
               │                     ││                     │
               │ • Azure Cognitive   ││ • uv (Python)       │
               │   Services          ││ • pnpm (Node.js)    │
               │ • PDF Processing    ││ • Git Version Ctrl  │
               │ • AI Document       ││ • VS Code           │
               │   Understanding     ││                     │
               └─────────────────────┘└─────────────────────┘
```

### Architecture Components

#### 🎨 Frontend Layer (React + Vite)

- **Modern UI Components**: Interactive study plan visualization with faculty-specific theming
- **PDF Upload Interface**: Drag-and-drop file upload with progress tracking
- **Real-time Updates**: Dynamic course status updates and progress tracking
- **Responsive Design**: Mobile-friendly interface with custom CSS styling

#### ⚙️ Backend Layer (FastAPI + Python)

- **API Endpoints**: RESTful API for document processing and data management
- **PDF Processing**: Azure Cognitive Services integration for document understanding
- **Data Processing**: Intelligent extraction and cleaning of study plan data
- **Database Management**: SQLite for efficient data storage and retrieval

#### 🔗 Data Flow Architecture

- **Upload → Process → Extract → Store → Display**
- **PDF files** are uploaded via frontend, processed by Azure AI, cleaned and structured by backend, stored in database, and displayed in interactive UI

#### 🛡️ Security & Performance

- **Environment Variables**: Sensitive configuration stored securely
- **File Validation**: Proper validation of uploaded PDF files
- **Error Handling**: Comprehensive error handling and user feedback
- **Optimized Dependencies**: Efficient package management with uv and pnpm

## Project Structure

```
mitrayectoriautp/
├── backend/                 # FastAPI backend
│   ├── main.py             # Main application and API routes
│   ├── models.py           # Data models and database schemas
│   ├── db.py               # Database connection and operations
│   ├── extractor.py        # PDF processing and data extraction
│   ├── utils/
│   │   └── cleaner.py      # Data cleaning utilities
│   ├── uploads/            # Uploaded PDF files (gitignored)
│   ├── requirements.txt    # Python dependencies
│   ├── pyproject.toml      # Project configuration
│   └── uv.lock             # Dependency lock file
├── frontend/               # React frontend
│   ├── src/
│   │   ├── App.jsx         # Main application component
│   │   ├── main.jsx        # Application entry point
│   │   ├── styles.css      # Custom CSS styles
│   │   ├── components/     # React components
│   │   │   ├── UploadPDF.jsx      # PDF upload interface
│   │   │   ├── StudyPlanViewer.jsx # Study plan display
│   │   │   ├── CourseSelector.jsx  # Course selection tools
│   │   │   └── DocControls.jsx     # Document management
│   │   └── services/
│   │       └── api.js      # API communication layer
│   ├── index.html          # HTML template
│   ├── package.json        # Node.js dependencies
│   ├── vite.config.js      # Vite configuration
│   └── pnpm-lock.yaml      # Dependency lock file
├── .gitignore              # Git ignore rules
├── Instruction.md          # Setup and running instructions
└── README.md               # This file
```

## Quick Start

### Prerequisites
- **Python 3.13+** with `uv` package manager
- **Node.js 18+** with `pnpm` package manager
- **Git** for version control

### Installation & Setup

1. **Install uv** (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Clone and setup backend**:
   ```bash
   cd backend
   uv add -r requirements.txt
   uv add uvicorn python-multipart
   ```

3. **Setup frontend**:
   ```bash
   cd ../frontend
   pnpm install
   ```

### Running the Application

1. **Start backend server**:
   ```bash
   cd backend
   PYTHONPATH=backend uv run -- python -m uvicorn backend.main:app --reload
   ```
   Backend available at: `http://127.0.0.1:8000`

2. **Start frontend server**:
   ```bash
   cd frontend
   pnpm dev
   ```
   Frontend available at: `http://localhost:5173`

## Environment Configuration

Create a `.env` file in the `backend/` directory for environment variables:
```env
# Add your environment variables here
# Example:
# DATABASE_URL=sqlite:///./app.db
# SECRET_KEY=your-secret-key-here
```

The frontend is pre-configured to connect to the backend.

## Usage

1. Start both servers (backend and frontend)
2. Open frontend in browser
3. Upload UTP study plan PDF
4. View and manage study plan
5. Track progress by marking completed courses

## Development

### Adding Features
- **Backend**: Add endpoints in `backend/main.py`
- **Frontend**: Create components in `frontend/src/components/`

### Database Changes
- Modify models in `backend/models.py`

### Styling
- Update styles in `frontend/src/styles.css`

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## License

This project is for educational and personal use at UTP.

## Support

Check `Instruction.md` or create an issue for questions.

