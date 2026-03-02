import './App.css';
import { useState } from 'react';

const URL = "http://localhost:20000/api/Save-JSON";

function App() {
  const [op, setOp] = useState("add");
  const [x, setX] = useState("");
  const [y, setY] = useState("");
  const [result, setResult] = useState("");

  const sendRequest = async(method) => {
    let options = {method};

    if (method === "POST" || method === "PUT") {
      options.headers = {"Content-Type": "application/json"};
      options.body = JSON.stringify({
        op,
        x: Number(x),
        y: Number(y)
      });
    }

    const response = await fetch(URL, options);

    if (method === "DELETE") {
      setResult({status: response.status});
      return;
    }

    if (response.status === 404) {
      setResult({status: response.status});
      return;
    }

    if (response.status === 409) {
      setResult({status: response.status});
      return;
    }

    const data = await response.json();
    setResult(data);
  }

  return (
    <div className="body">
      <h1>TDWA02-01</h1>
      
      <div class="controls">
          <label>Operation:
              <select value={op} onChange={e => setOp(e.target.value)}>
                  <option value="add">add</option>
                  <option value="sub">sub</option>
                  <option value="mul">mul</option>
                  <option value="div">div</option>
              </select>
          </label>

          <label>X:
              <input type="number" value={x} onChange={e => setX(e.target.value)} placeholder='0'/>
          </label>

          <label>Y:
              <input type="number" value={y} onChange={e => setY(e.target.value)} placeholder='0'/>
          </label>
      </div>

      <div class="buttons">
          <button onClick={() => sendRequest("GET")}>GET</button>
          <button onClick={() => sendRequest("POST")}>POST</button>
          <button onClick={() => sendRequest("PUT")}>PUT</button>
          <button onClick={() => sendRequest("DELETE")}>DELETE</button>
      </div>

      <h2>Result:</h2>
      <pre>{result && JSON.stringify(result, null, 2)}</pre>
    </div>
  );
}

export default App;
