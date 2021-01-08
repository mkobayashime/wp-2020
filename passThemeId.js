window.onload = () => {
  const themeIdInput = document.getElementById("theme_id")
  const searchParams = new URLSearchParams(window.location.search)
  themeIdInput.value = searchParams.get("theme_id")
}