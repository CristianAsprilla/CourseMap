import axios from 'axios'

const client = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000',
})

export async function uploadPdf(file) {
  const form = new FormData()
  form.append('file', file)
  const { data } = await client.post('/upload/pdf', form, {
    headers: { 'Content-Type': 'multipart/form-data' },
  })
  return data
}

export async function uploadJson(plan) {
  const { data } = await client.post('/upload/json', plan)
  return data
}

export async function getDocument(docId) {
  const { data } = await client.get(`/documents/${encodeURIComponent(docId)}`)
  return data
}

export async function getDocumentByName(name) {
  const { data } = await client.get(`/documents/by-name/${encodeURIComponent(name)}`)
  return data
}

export async function setDocumentName(docId, name) {
  const params = new URLSearchParams({ name })
  const { data } = await client.post(`/documents/${encodeURIComponent(docId)}/name?${params}`)
  return data
}

export async function setCourseStatus(docId, codAsig, passed) {
  const params = new URLSearchParams({ passed: String(!!passed) })
  const { data } = await client.post(`/documents/${encodeURIComponent(docId)}/courses/${encodeURIComponent(codAsig)}/status?${params}`)
  return data
}


