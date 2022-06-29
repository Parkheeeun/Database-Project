create or replace NONEDITIONABLE PACKAGE PKG_MENU AS 

--CRUD

--1. 입력 INSERT
PROCEDURE PROC_INS_MENU
(
    IN_STORE_ID        IN              VARCHAR2,
    IN_MENU_GRP_CODE   IN              VARCHAR2,
    IN_MENU_CODE1      IN              VARCHAR2,
    IN_MENU_CODE2      IN              VARCHAR2,
    IN_MENU_PRICE      IN              NUMBER,
    O_ERR_CODE         OUT             VARCHAR2,
    O_ERR_MSG          OUT             VARCHAR2
);

--2. 조회 SELECT
PROCEDURE PROC_SEL_MENU
(
    IN_MENU_ID         IN              VARCHAR2,
    IN_MENU_CA         IN              VARCHAR2,
    IN_MENU_NAME       IN              VARCHAR2,
    O_CURSOR           OUT             SYS_REFCURSOR,
    O_ERR_CODE         OUT             VARCHAR2,
    O_ERR_MSG          OUT             VARCHAR2
);

--3. 수정 UPDATE
PROCEDURE PROC_UP_MENU
(
    IN_MENU_ID         IN              CHAR,
    IN_STORE_ID        IN              VARCHAR2,
    IN_MENU_GRP_CODE   IN              VARCHAR2,
    IN_MENU_CODE1      IN              VARCHAR2,
    IN_MENU_CODE2      IN              VARCHAR2,
    IN_MENU_PRICE      IN              NUMBER,
    O_ERR_CODE         OUT             VARCHAR2,
    O_ERR_MSG          OUT             VARCHAR2
);

--4. 삭제 DELETE
PROCEDURE PROC_DEL_MENU
(
    IN_MENU_ID         IN              CHAR,
    O_ERR_CODE         OUT             VARCHAR2,
    O_ERR_MSG          OUT             VARCHAR2
);

END PKG_MENU;