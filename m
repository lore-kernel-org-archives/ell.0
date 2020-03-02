Content-Type: multipart/mixed; boundary="===============7422175412367426491=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/4] Refactor timespec to microsecond conversion
Date: Mon, 02 Mar 2020 13:28:13 -0800
Message-ID: <20200302212817.15524-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7422175412367426491==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

An integer overflow fix for a timespec to microsecond conversion in
l_path_get_mtime() was previously committed but two overflows could
still occur: (1) the multiplication in the seconds (tv_sec) to
microsecond conversion could still exceed UINT64_MAX, and (2) addition
of the microseconds obtained from the nanoseconds (tv_nsec) member
could also result in a sum that exceeds UINT64_MAX.

This set of patches refactors the timespec to microsecond to a new
l_timespec_to_usecs() function that checks for overflow in both of the
cases mentioned above.  The l_path_get_mtime() function now uses
l_timespec_to_usecs() to address the remaining potential integer
overflows.  A potential integer overflow in the l_time_now() function
was corrected in a similar manner.


Ossama Othman (4):
  time: Add timespec to microseconds converter
  unit: Add l_timespec_to_usecs() unit test.
  time: Use l_timespec_to_usecs() to avoid overflow.
  path: Use l_timespec_to_usecs() to avoid overflow.

 ell/ell.sym      |  1 +
 ell/path.c       |  3 +--
 ell/time.c       | 26 +++++++++++++++++++++++++-
 ell/time.h       |  3 +++
 unit/test-time.c | 34 ++++++++++++++++++++++++++++++++++
 5 files changed, 64 insertions(+), 3 deletions(-)

-- =

2.20.1

--===============7422175412367426491==--

