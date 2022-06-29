create or replace NONEDITIONABLE PACKAGE PKG_STORE AS

    --INSERT 시작
   PROCEDURE PROC_INS_STORE
   (
        IN_STORE_CA_GRP      IN  VARCHAR2,
        IN_STORE_CA_COM      IN  VARCHAR2,
        IN_STORE_NAME        IN  VARCHAR2,
        IN_STORE_ADDR_GRP    IN  VARCHAR2,
        IN_STORE_ADDR        IN  VARCHAR2,
        IN_STORE_ADDR2       IN  VARCHAR2,
        IN_STORE_ADDR3       IN  VARCHAR2,
        IN_STORE_TEL         IN  VARCHAR2,
        IN_OPEN_TIME         IN  VARCHAR2,
        IN_CLOSE_TIME        IN  VARCHAR2,
        IN_MIN_PRICE         IN  NUMBER,
        IN_STORE_SCORE       IN  NUMBER,
        O_ERRCODE            OUT VARCHAR2,
        O_ERRMSG             OUT VARCHAR2
   );
   --INSERT 끝
   
   --SELECT 시작
   PROCEDURE PROC_SEL_STORE
   (
      IN_STORE_ID   IN  VARCHAR2,
      IN_STORE_NAME IN  VARCHAR2,
      O_CURSOR         OUT SYS_REFCURSOR,
      O_ERRCODE     OUT VARCHAR2,
      O_ERRMSG      OUT VARCHAR2
   );
   --SELECT 끝
   
   --UPDATE 시작
   PROCEDURE PROC_UP_STORE
   (
        IN_STORE_ID          IN  VARCHAR2,
        IN_STORE_CA_GRP      IN  VARCHAR2,
        IN_STORE_CA_COM      IN  VARCHAR2,
        IN_STORE_NAME        IN  VARCHAR2,
        IN_STORE_ADDR_GRP    IN  VARCHAR2,
        IN_STORE_ADDR        IN  VARCHAR2,
        IN_STORE_ADDR2       IN  VARCHAR2,
        IN_STORE_ADDR3       IN  VARCHAR2,
        IN_STORE_TEL         IN  VARCHAR2,
        IN_OPEN_TIME         IN  VARCHAR2,
        IN_CLOSE_TIME        IN  VARCHAR2,
        IN_MIN_PRICE         IN  NUMBER,
        IN_STORE_SCORE       IN  NUMBER,
        O_ERRCODE            OUT VARCHAR2,
        O_ERRMSG             OUT VARCHAR2
     
   );
   --UPDATE 끝
  
   --DELETE 시작
   PROCEDURE PROC_DEL_STORE
   (
        IN_STORE_ID IN VARCHAR2,
        O_ERRCODE   OUT VARCHAR2,
        O_ERRMSG    OUT VARCHAR2
   );
    --DELETE 끝
END;