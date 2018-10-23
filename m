Content-Type: multipart/mixed; boundary="===============9093384024456917116=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/2] Correct missing field initializer warning
Date: Tue, 23 Oct 2018 12:57:38 -0700
Message-ID: <20181023195740.30204-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9093384024456917116==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The L_PLUGIN_DEFINE() macro triggered missing field initializer
warnings when the corresponding warning flag was enabled for user
defined plugins.  Prevent ELL from exposing such warnings to the user
by explicitly initializing all l_plugin_desc fields, as well
re-enabling that warning in maintainer mode builds.

Ossama Othman (2):
  plugin: Explicitly initialize descriptor fields.
  Re-enable -Wmissing-field-initializers warning.

 acinclude.m4 | 1 -
 ell/plugin.h | 3 ++-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- =

2.17.1


--===============9093384024456917116==--

