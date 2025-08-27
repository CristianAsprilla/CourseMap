import React, { useEffect, useRef, useState } from 'react'
import UploadPDF from './components/UploadPDF'
import StudyPlanViewer from './components/StudyPlanViewer'
import CourseSelector from './components/CourseSelector'
import DocControls from './components/DocControls'

export default function App() {
  const [plan, setPlan] = useState(null)
  const [loading, setLoading] = useState(false)
  const [toast, setToast] = useState('')
  const planRef = useRef(null)

  const handleResult = (data) => {
    setPlan(data)
    setToast('Documento procesado correctamente')
    setTimeout(() => setToast(''), 2500)
    // Smooth scroll to plan section
    requestAnimationFrame(() => {
      planRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    })
  }

  const facultyColor = (fac) => {
    if (!fac) return null
    const map = {
      'CIENCIAS Y TECNOLOGÍA': '#ff7e00',
      'INGENIERÍA CIVIL': '#610563',
      'INGENIERÍA ELÉCTRICA': '#0090d9',
      'INGENIERÍA INDUSTRIAL': '#1b65a2',
      'INGENIERÍA MECÁNICA': '#90244f',
      'INGENIERÍA DE SISTEMAS COMPUTACIONALES': '#237c2c',
    }
    return map[fac] || null
  }

  const hexToRgba = (hex, alpha) => {
    if (!hex) return 'transparent'
    const m = hex.replace('#','')
    const bigint = parseInt(m, 16)
    const r = (bigint >> 16) & 255
    const g = (bigint >> 8) & 255
    const b = bigint & 255
    return `rgba(${r}, ${g}, ${b}, ${alpha})`
  }

  // Apply faculty color to the global CSS variable so body can consume it
  useEffect(() => {
    const color = facultyColor(plan?.FACULTAD)
    const value = color ? hexToRgba(color, 0.4) : 'transparent'
    document.documentElement.style.setProperty('--faculty-rgba', value)
    
    // Set faculty-specific button colors for better integration
    if (color) {
      // Create slightly lighter and darker variants for buttons
      const lighterColor = adjustBrightness(color, 20) // 20% lighter
      const darkerColor = adjustBrightness(color, -20) // 20% darker
      const hoverColor = adjustBrightness(color, 10) // 10% lighter for hover
      const hoverDarkColor = adjustBrightness(color, -10) // 10% darker for hover
      
      document.documentElement.style.setProperty('--faculty-primary', lighterColor)
      document.documentElement.style.setProperty('--faculty-primary-dark', darkerColor)
      document.documentElement.style.setProperty('--faculty-primary-hover', hoverColor)
      document.documentElement.style.setProperty('--faculty-primary-dark-hover', hoverDarkColor)
    } else {
      // Reset to default colors
      document.documentElement.style.setProperty('--faculty-primary', 'var(--primary)')
      document.documentElement.style.setProperty('--faculty-primary-dark', 'var(--primary-600)')
      document.documentElement.style.setProperty('--faculty-primary-hover', 'var(--primary-600)')
      document.documentElement.style.setProperty('--faculty-primary-dark-hover', '#4338ca')
    }
    
    return () => {
      // optional cleanup on unmount
    }
  }, [plan])
  
  // Helper function to adjust color brightness
  const adjustBrightness = (hex, percent) => {
    if (!hex) return hex
    const num = parseInt(hex.replace('#', ''), 16)
    const amt = Math.round(2.55 * percent)
    const R = (num >> 16) + amt
    const G = (num >> 8 & 0x00FF) + amt
    const B = (num & 0x0000FF) + amt
    return '#' + (0x1000000 + (R < 255 ? R < 1 ? 0 : R : 255) * 0x10000 +
      (G < 255 ? G < 1 ? 0 : G : 255) * 0x100 +
      (B < 255 ? B < 1 ? 0 : B : 255)).toString(16).slice(1)
  }

  return (
    <div className="container">
      <div className="header">
        <div>
          <h1 className="title">Mi Trayectoria UTP</h1>
          <div className="subtitle">Sube tu plan, nómbralo y gestiona tu avance</div>
          {/* Info del plan se mostrará en una tarjeta dedicada más abajo */}
        </div>
      </div>

      <div className="grid">
        <div className="card card-lg">
          <h2>Documento</h2>
          <div className="muted">Cargar por DOC_ID o definir nombre</div>
          <div className="spacer" />
          <DocControls plan={plan} setPlan={setPlan} />
        </div>

        <div className="card card-lg">
          <h2>Subir PDF</h2>
          <div className="muted">Primera carga desde PDF (o vuelve a procesar)</div>
          <div className="spacer" />
          <UploadPDF onResult={handleResult} setLoading={setLoading} />
        </div>
      </div>

      {plan && (
        <div className="spacer" />
      )}

      {plan && (
        <div className="card card-lg">
          <h2>Información del plan</h2>
          <div className="spacer" />
          <div className="row" style={{ gap: 12, flexWrap: 'wrap' }}>
            <span className="badge" style={{ fontSize: 14 }}>Facultad: {plan.FACULTAD || '—'}</span>
            <span className="badge" style={{ fontSize: 14 }}>Carrera: {plan.CARRERA || '—'}</span>
            {plan.NAME && <span className="badge" style={{ fontSize: 14 }}>Nombre: {plan.NAME}</span>}
          </div>
        </div>
      )}

      <div className="spacer" />

      <div className="card" ref={planRef}>
        <h2>Plan de estudios</h2>
        <div className="muted">Marca cursos aprobados, revisa elegibles</div>
        <div className="spacer" />
        <StudyPlanViewer plan={plan} />
      </div>

      {loading && (
        <div className="overlay">
          <div className="overlay-card">
            <div className="spinner" />
            <div>Procesando documento…</div>
          </div>
        </div>
      )}

      {toast && (
        <div className="toast">{toast}</div>
      )}
    </div>
  )
}


