import React, { useEffect, useMemo, useState } from 'react'
import { setCourseStatus } from '../services/api'

export default function StudyPlanViewer({ plan }) {
  const [busy, setBusy] = useState(false)
  if (!plan) return <div>Aún no hay un plan cargado.</div>

  return (
    <div>
      <CoursesTable plan={plan} busy={busy} setBusy={setBusy} />
    </div>
  )
}

function CoursesTable({ plan, busy, setBusy }) {
  const docId = plan.DOC_ID
  const rawCourses = Array.isArray(plan.PLAN) ? plan.PLAN : []

  const normalize = (arr) => (arr || []).map((c) => {
    const requisitos = Array.isArray(c.REQUISITOS)
      ? c.REQUISITOS.map((r) => String(r))
      : c.REQUISITOS == null
        ? []
        : [String(c.REQUISITOS)]
    return {
      ...c,
      COD_ASIG: String(c.COD_ASIG),
      REQUISITOS: requisitos,
      PASSED: Boolean(c.PASSED),
    }
  })

  const [courses, setCourses] = useState(normalize(rawCourses))
  useEffect(() => {
    setCourses(normalize(rawCourses))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [plan])

  const passedSet = useMemo(() => new Set(courses.filter(c => c.PASSED).map(c => c.COD_ASIG)), [courses])
  const nextEligible = useMemo(() => {
    return courses
      .filter(c => c.REQUISITOS.every(r => passedSet.has(String(r))) && !c.PASSED)
      .map(c => c.COD_ASIG)
  }, [courses, passedSet])
  const codeToMeta = useMemo(() => {
    const m = {}
    for (const c of courses) m[c.COD_ASIG] = { name: c.ASIGNATURA, year: c.AÑO, term: c.SEMESTRE }
    return m
  }, [courses])

  const toggle = async (c) => {
    setBusy(true)
    try {
      const newPassed = !c.PASSED
      await setCourseStatus(docId, c.COD_ASIG, newPassed)
      setCourses(prev => prev.map(x => x.COD_ASIG === c.COD_ASIG ? { ...x, PASSED: newPassed } : x))
    } finally {
      setBusy(false)
    }
  }

  const [view, setView] = useState('table') // 'table' | 'cards'

  return (
    <div>
      <div className="row" style={{ justifyContent: 'space-between', margin: '8px 0' }}>
        <div className="row" style={{ gap: 6, flexWrap: 'wrap' }}>
          <span className="badge">Elegibles:</span>
          {nextEligible.length === 0 ? (
            <span className="badge">—</span>
          ) : (
            nextEligible.map(code => (
              <span
                key={code}
                className="badge"
                title={(codeToMeta[code]?.name || '') + "\n" + (codeToMeta[code] ? (`${codeToMeta[code].year}-${codeToMeta[code].term}`) : '')}
                style={{ background: 'linear-gradient(180deg,#22d3ee,#0891b2)', color: 'white', border: 'none', cursor: 'help' }}
              >
                {code}
              </span>
            ))
          )}
        </div>
        <div className="row" style={{ gap: 6 }}>
          <button className={`btn ${view === 'table' ? 'btn-primary' : ''}`} onClick={() => setView('table')}>Tabla</button>
          <button className={`btn ${view === 'cards' ? 'btn-primary' : ''}`} onClick={() => setView('cards')}>Tarjetas</button>
        </div>
      </div>

      {view === 'table' ? (
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr>
            <th align="left">Código</th>
            <th align="left">Asignatura</th>
            <th align="left">Requisitos</th>
            <th align="left">Fundamental</th>
            <th align="left">Semestre</th>
            <th align="left">Aprobado</th>
          </tr>
        </thead>
        <tbody>
          {courses.map((c) => (
            <tr key={c.COD_ASIG}>
              <td><CourseBadge c={c} eligible={c.REQUISITOS.every(r => passedSet.has(String(r))) && !c.PASSED} /></td>
              <td>{c.ASIGNATURA}</td>
              <td>{(Array.isArray(c.REQUISITOS) ? c.REQUISITOS : []).join(', ')}</td>
              <td>{c.FUNDAMENTAL ? 'Sí' : 'No'}</td>
              <td>{c.AÑO}-{c.SEMESTRE}</td>
              <td>
                <label>
                  <input type="checkbox" disabled={busy} checked={!!c.PASSED} onChange={() => toggle(c)} />
                </label>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: 12 }}>
          {courses.map((c) => (
            <div key={c.COD_ASIG} className="card">
              <div className="row" style={{ justifyContent: 'space-between' }}>
                <CourseBadge c={c} eligible={c.REQUISITOS.every(r => passedSet.has(String(r))) && !c.PASSED} />
                <label className="row" style={{ gap: 6 }}>
                  <input type="checkbox" disabled={busy} checked={!!c.PASSED} onChange={() => toggle(c)} />
                  <span className="badge">{c.PASSED ? 'Aprobado' : 'Pendiente'}</span>
                </label>
              </div>
              <div className="spacer" />
              <div style={{ fontWeight: 600 }}>{c.ASIGNATURA}</div>
              <div className="muted">Semestre {c.AÑO}-{c.SEMESTRE}</div>
              <div className="spacer" />
              <div className="muted" style={{ fontSize: 12 }}>Requisitos: {(Array.isArray(c.REQUISITOS) ? c.REQUISITOS : []).join(', ') || '—'}</div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

function CourseBadge({ c, eligible }) {
  // Colores: aprobado (verde), elegible (cian), bloqueado (rojo), pendiente (gris)
  let bg = 'linear-gradient(180deg,#4b5563,#374151)' // pendiente
  if (c.PASSED) bg = 'linear-gradient(180deg,#16a34a,#15803d)'
  else if (eligible) bg = 'linear-gradient(180deg,#22d3ee,#0891b2)'
  else if (!eligible && (Array.isArray(c.REQUISITOS) ? c.REQUISITOS.length > 0 : false)) bg = 'linear-gradient(180deg,#ef4444,#b91c1c)'
  return (
    <span className="badge" style={{ background: bg, color: 'white', border: 'none' }}>{c.COD_ASIG}</span>
  )
}


