create or replace NONEDITIONABLE PACKAGE PKG_DRIVER AS 

  --배달기사 등록 프로시저
  PROCEDURE PROC_INS_DRIVER
  (
    IN_DRIVER_NAME  IN VARCHAR2,
    IN_DRIVER_TEL   IN VARCHAR2,
    O_ERRCODE       OUT VARCHAR2,
    O_ERRMSG        OUT VARCHAR2
  );
  
  --배달기사 조회 프로시저
  PROCEDURE PROC_SEL_DRIVER
  (
    IN_DRIVER_ID    IN VARCHAR2,
    IN_DRIVER_NAME  IN VARCHAR2,
    O_CUR           OUT SYS_REFCURSOR,
    O_ERRCODE       OUT VARCHAR2,
    O_ERRMSG        OUT VARCHAR2
  );
  
  --배달기사 수정 프로시저
  PROCEDURE PROC_UP_DRIVER
  (
    IN_DRIVER_ID    IN VARCHAR2,
    IN_DRIVER_NAME  IN VARCHAR2,
    IN_DRIVER_TEL   IN VARCHAR2,
    O_ERRCODE       OUT VARCHAR2,
    O_ERRMSG        OUT VARCHAR2
  );
  
  --배달기사 삭제 프로시저
  PROCEDURE PROC_DEL_DRIVER
  (
    IN_DRIVER_ID    IN VARCHAR2,
    O_ERRCODE      OUT VARCHAR2,
    O_ERRMSG       OUT VARCHAR2
  );

END PKG_DRIVER;