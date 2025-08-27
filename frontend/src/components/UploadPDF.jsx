import React, { useState } from 'react'
import { uploadPdf } from '../services/api'

export default function UploadPDF({ onResult, setLoading }) {
  const [file, setFile] = useState(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')

  const handleUpload = async () => {
    if (!file) return
    setBusy(true)
    setLoading && setLoading(true)
    setError('')
    try {
      const data = await uploadPdf(file)
      onResult && onResult(data)
    } catch (e) {
      setError('Upload failed')
    } finally {
      setBusy(false)
      setLoading && setLoading(false)
    }
  }

  return (
    <div className="row" style={{ gap: 8 }}>
      <div className="file">
        <label className="file-label" htmlFor="pdf-input">Seleccionar PDF</label>
        <input id="pdf-input" type="file" accept="application/pdf" onChange={(e) => setFile(e.target.files?.[0] || null)} />
        <span className="file-name">{file ? file.name : 'Ningún archivo seleccionado'}</span>
      </div>
      <button className="btn btn-primary" onClick={handleUpload} disabled={!file || busy}>{busy ? 'Subiendo…' : 'Subir PDF'}</button>
      {error && <span className="badge" style={{ background: 'linear-gradient(180deg,#ef4444,#b91c1c)', color: 'white', border: 'none' }}>{error}</span>}
    </div>
  )
}
