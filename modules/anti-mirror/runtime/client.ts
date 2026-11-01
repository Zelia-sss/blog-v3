export default (sourcesEncoded: string[], targetEncoded: string) => {
	const sources = sourcesEncoded.map(atob)
	const target = new URL(atob(targetEncoded))
	const isBadMirror = sources.some(domain => location.hostname === domain || location.hostname.endsWith(`.${domain}`))
	if (!isBadMirror)
		return

	const current = new URL(location.href)
	current.protocol = target.protocol
	current.host = target.host

	const canonical = document.querySelector<HTMLLinkElement>('link[rel="canonical"]')
	if (canonical)
		canonical.href = current.href

	location.replace(current.href)
}
