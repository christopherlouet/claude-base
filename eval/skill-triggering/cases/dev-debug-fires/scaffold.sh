#!/bin/bash
# A real bug to look at: `items` is undefined when the API returns no body.
cat > list.js <<'JS'
function titles(response) {
  const items = response.data;
  return items.map((i) => i.title);
}
console.log(titles({ data: [{ title: "a" }] }));
console.log(titles({}));
JS
