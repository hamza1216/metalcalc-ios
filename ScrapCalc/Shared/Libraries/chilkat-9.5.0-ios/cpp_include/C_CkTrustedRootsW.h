// This is a generated source file for Chilkat version 9.5.0.40
#ifndef _C_CkTrustedRootsWH
#define _C_CkTrustedRootsWH
#include "chilkatDefs.h"

#include "Chilkat_C.h"

CK_VISIBLE_PUBLIC HCkTrustedRootsW CkTrustedRootsW_Create(void);
CK_VISIBLE_PUBLIC HCkTrustedRootsW CkTrustedRootsW_Create2(BOOL bCallbackOwned);
CK_VISIBLE_PUBLIC void CkTrustedRootsW_Dispose(HCkTrustedRootsW handle);
CK_VISIBLE_PUBLIC void CkTrustedRootsW_getDebugLogFilePath(HCkTrustedRootsW cHandle, HCkString retval);
CK_VISIBLE_PUBLIC void CkTrustedRootsW_putDebugLogFilePath(HCkTrustedRootsW cHandle, const wchar_t *newVal);
CK_VISIBLE_PUBLIC const wchar_t *CkTrustedRootsW_debugLogFilePath(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC void CkTrustedRootsW_getLastErrorHtml(HCkTrustedRootsW cHandle, HCkString retval);
CK_VISIBLE_PUBLIC const wchar_t *CkTrustedRootsW_lastErrorHtml(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC void CkTrustedRootsW_getLastErrorText(HCkTrustedRootsW cHandle, HCkString retval);
CK_VISIBLE_PUBLIC const wchar_t *CkTrustedRootsW_lastErrorText(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC void CkTrustedRootsW_getLastErrorXml(HCkTrustedRootsW cHandle, HCkString retval);
CK_VISIBLE_PUBLIC const wchar_t *CkTrustedRootsW_lastErrorXml(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC int CkTrustedRootsW_getNumCerts(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC BOOL CkTrustedRootsW_getVerboseLogging(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC void CkTrustedRootsW_putVerboseLogging(HCkTrustedRootsW cHandle, BOOL newVal);
CK_VISIBLE_PUBLIC void CkTrustedRootsW_getVersion(HCkTrustedRootsW cHandle, HCkString retval);
CK_VISIBLE_PUBLIC const wchar_t *CkTrustedRootsW_version(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC BOOL CkTrustedRootsW_Activate(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC BOOL CkTrustedRootsW_Deactivate(HCkTrustedRootsW cHandle);
CK_VISIBLE_PUBLIC HCkCertW CkTrustedRootsW_GetCert(HCkTrustedRootsW cHandle, int index);
CK_VISIBLE_PUBLIC BOOL CkTrustedRootsW_LoadCaCertsPem(HCkTrustedRootsW cHandle, const wchar_t *path);
CK_VISIBLE_PUBLIC BOOL CkTrustedRootsW_SaveLastError(HCkTrustedRootsW cHandle, const wchar_t *path);
#endif
