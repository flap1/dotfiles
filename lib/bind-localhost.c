/*
 * Force every wildcard bind() onto loopback.
 *
 * For servers with no way to choose a listen address. remotion studio is the
 * case this was written for: it takes --port but has no --host, no HOST
 * environment variable, and its config API exposes only setStudioPort, so it
 * listens on 0.0.0.0 and is reachable from the LAN. On a shared machine that is
 * not acceptable, and the alternatives all need root -- a packet filter, or
 * systemd's IPAddressAllow, which a user unit silently ignores ("unit configures
 * an IP firewall, but not running as root").
 *
 *   LD_PRELOAD=~/.local/lib/bind-localhost.so <server>
 *
 * Only a wildcard address is rewritten. A server that asks for a specific
 * address already knows what it wants and is left alone.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <netinet/in.h>
#include <string.h>
#include <sys/socket.h>

typedef int (*bind_fn)(int, const struct sockaddr *, socklen_t);

int bind(int fd, const struct sockaddr *addr, socklen_t len)
{
	static bind_fn real;
	if (!real)
		real = (bind_fn)dlsym(RTLD_NEXT, "bind");

	if (!addr)
		return real(fd, addr, len);

	if (addr->sa_family == AF_INET && len >= sizeof(struct sockaddr_in)) {
		struct sockaddr_in v4;
		memcpy(&v4, addr, sizeof v4);
		if (v4.sin_addr.s_addr == htonl(INADDR_ANY)) {
			v4.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
			return real(fd, (const struct sockaddr *)&v4, sizeof v4);
		}
	} else if (addr->sa_family == AF_INET6 && len >= sizeof(struct sockaddr_in6)) {
		struct sockaddr_in6 v6;
		memcpy(&v6, addr, sizeof v6);
		if (memcmp(&v6.sin6_addr, &in6addr_any, sizeof v6.sin6_addr) == 0) {
			/*
			 * ::ffff:127.0.0.1 rather than ::1. Node binds a dual-stack
			 * v6 socket, and one bound to ::1 stops accepting connections
			 * to 127.0.0.1 -- which is what an ssh port forward uses.
			 */
			static const unsigned char v4_mapped_loopback[16] = {
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xff, 0xff, 127, 0, 0, 1
			};
			memcpy(&v6.sin6_addr, v4_mapped_loopback, sizeof v4_mapped_loopback);
			return real(fd, (const struct sockaddr *)&v6, sizeof v6);
		}
	}

	return real(fd, addr, len);
}
