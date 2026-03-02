async function loadData() {
    const jsonRes = await fetch('/data.json');
    const json = await jsonRes.json();

    document.getElementById('json').textContent = JSON.stringify(json, null, 2);

    const xmlRes = await fetch('/data.xml');
    const xmlText = await xmlRes.text();
    
    document.getElementById('xml').textContent = xmlText;
}

window.onload = loadData;
