create or replace NONEDITIONABLE PACKAGE PKG_REVIEW AS 
  
  --리뷰 등록 프로시저
  PROCEDURE PROC_INS_REVIEW
  (
    IN_ORDER_ID         IN VARCHAR2,
    IN_S_SCORE          IN VARCHAR2,
    IN_REVIEW_COMMENT   IN VARCHAR2,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );
  
  --리뷰 조회 프로시저
  PROCEDURE PROC_SEL_REVIEW
  (
    IN_USER_ID          IN VARCHAR2,
    IN_ORDER_ID         IN VARCHAR2,
    IN_S_SCORE          IN VARCHAR2,
    IN_REVIEW_DATE      IN VARCHAR2,
    O_CUR               OUT SYS_REFCURSOR,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );
  
  --리뷰 수정 프로시저
  PROCEDURE PROC_UP_REVIEW
  (
    IN_REVIEW_ID        IN VARCHAR,
    IN_USER_ID          IN VARCHAR2,
    IN_ORDER_ID         IN VARCHAR2,
    IN_S_SCORE          IN VARCHAR2,
    IN_REVIEW_COMMENT   IN VARCHAR2,
    O_ERRCODE           OUT VARCHAR2,
    O_ERRMSG            OUT VARCHAR2
  );
  
  --리뷰 삭제 프로시저
  PROCEDURE PROC_DEL_REVIEW
    (
    INS_IDX IN INTEGER,
    O_ERRCODE OUT VARCHAR2,
    O_ERRMSG OUT VARCHAR2
    );

  PROCEDURE PROC_UP_SCORE;

END PKG_REVIEW;