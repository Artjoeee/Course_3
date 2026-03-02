const URL = "http://localhost:20000/api/Save-JSON";

function getInputData() {
    return {
        op: document.getElementById("op").value,
        x: Number(document.getElementById("x").value),
        y: Number(document.getElementById("y").value)
    }
}

function showResult(data) {
    document.getElementById("result").textContent =
        JSON.stringify(data, null, 2);
}

async function sendGet() {
    const response = await fetch(URL, {method: "GET"});
    
    if (response.status === 404) {
        return showResult({status: response.status});
    }

    const data = await response.json();

    showResult(data);
}

async function sendPost() {
    const response = await fetch(URL, {
        method: "POST",
        headers: {"Content-type": "application/json"},
        body: JSON.stringify(getInputData())
    });

    if (response.status === 409) {
        showResult({status: response.status});
    }

    const data = await response.json();
    showResult(data);
}

async function sendPut() {
    const response = await fetch(URL, {
        method: "PUT",
        headers: {"Content-type": "application/json"},
        body: JSON.stringify(getInputData())
    });

    if (response.status === 404) {
        return showResult({status: response.status});
    }

    const data = await response.json();
    showResult(data);
}

async function sendDelete() {
    const response = await fetch(URL, {method: "DELETE"});

    if (response.status === 404) {
        return showResult({status: response.status});
    }

    showResult({status: response.status});
}