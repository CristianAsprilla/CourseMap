import React, { useState } from 'react'

export default function CourseSelector() {
  const [selected, setSelected] = useState([])
  const courses = [] // Hook up real courses later

  const toggle = (c) => {
    setSelected((prev) => prev.includes(c) ? prev.filter(x => x !== c) : [...prev, c])
  }

  return (
    <div>
      <h2>Course Selector</h2>
      {courses.length === 0 ? (
        <div>No courses available.</div>
      ) : (
        <ul>
          {courses.map((c) => (
            <li key={c}>
              <label>
                <input type="checkbox" checked={selected.includes(c)} onChange={() => toggle(c)} />
                {c}
              </label>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}


