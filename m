Content-Type: multipart/mixed; boundary="===============2188546135988577320=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH 0/2] io error/disconnect fixes
Date: Mon, 12 Oct 2020 15:13:52 -0700
Message-ID: <20201012221354.242562-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2188546135988577320==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patchset addresses cases when an error condition is detected in
io_callback() and, as a result, io is closed (disconnected), socket is
closed and disconnect hanler (if set) is called.

The current implementation closes the socket first and only then informs the
client that a disconnect has occured. At this point socket error condition,
e.g., ECONNREFUSED, is lost and this potentially prevents the client to take
different course of action that may have depended on the error.

Also, a disconnect callback is removed from the l_io_destroy(). The reasoni=
ng
here is that since l_io_destroy is an API function and is invoked by a clie=
nt,
there is no reason to inform that same clinet that the IO has been disconne=
cted.
This allows avoiding some circuitous logic in ell/io.c

Inga Stotland (2):
  io: Do not call disconnect handler in destroyer
  io: Allow socket error to be retrieved on disconnect

 ell/io.c | 33 ++++++++++-----------------------
 1 file changed, 10 insertions(+), 23 deletions(-)

-- =

2.26.2

--===============2188546135988577320==--

