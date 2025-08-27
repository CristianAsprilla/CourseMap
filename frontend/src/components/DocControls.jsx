import React, { useState } from 'react'
import { getDocument, getDocumentByName, setDocumentName } from '../services/api'

export default function DocControls({ plan, setPlan }) {
  const [docId, setDocId] = useState('')
  const [name, setName] = useState(plan?.NAME || '')
  const [lookupName, setLookupName] = useState('')
  const [busy, setBusy] = useState(false)
  const currentDocId = plan?.DOC_ID

  const load = async () => {
    if (!docId) return
    setBusy(true)
    try {
      const data = await getDocument(docId)
      setPlan(data)
      setName(data.NAME || '')
    } finally {
      setBusy(false)
    }
  }

  const loadByName = async () => {
    if (!lookupName) return
    setBusy(true)
    try {
      const data = await getDocumentByName(lookupName)
      setPlan(data)
      setName(data.NAME || '')
    } finally {
      setBusy(false)
    }
  }

  const saveName = async () => {
    if (!currentDocId || !name) return
    setBusy(true)
    try {
      await setDocumentName(currentDocId, name)
      setPlan({ ...plan, NAME: name })
    } finally {
      setBusy(false)
    }
  }

  return (
    <div style={{ display: 'flex', gap: 12, alignItems: 'center', flexWrap: 'wrap' }}>
      <div className="row" style={{ gap: 8 }}>
        <input className="input" placeholder="DOC_ID" value={docId} onChange={e => setDocId(e.target.value)} />
        <button className="btn btn-primary" onClick={load} disabled={busy || !docId}>Cargar</button>
      </div>
      <div className="row" style={{ gap: 8 }}>
        <input className="input" placeholder="Nombre" value={lookupName} onChange={e => setLookupName(e.target.value)} />
        <button className="btn" onClick={loadByName} disabled={busy || !lookupName}>Cargar por nombre</button>
      </div>
      <div className="row" style={{ gap: 8 }}>
        <input className="input" placeholder="Nombre del documento" value={name} onChange={e => setName(e.target.value)} />
        <button className="btn" onClick={saveName} disabled={busy || !currentDocId || !name}>Guardar nombre</button>
      </div>
      {currentDocId && <span className="badge">DOC_ID actual: {currentDocId}</span>}
    </div>
  )
}


