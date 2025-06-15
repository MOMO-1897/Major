/*
  Warnings:

  - Made the column `certificationImage` on table `SpecialistProfile` required. This step will fail if there are existing NULL values in that column.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_SpecialistProfile" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "specialization" TEXT NOT NULL,
    "certificationImage" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "userId" INTEGER NOT NULL,
    CONSTRAINT "SpecialistProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_SpecialistProfile" ("certificationImage", "createdAt", "id", "specialization", "updatedAt", "userId") SELECT "certificationImage", "createdAt", "id", "specialization", "updatedAt", "userId" FROM "SpecialistProfile";
DROP TABLE "SpecialistProfile";
ALTER TABLE "new_SpecialistProfile" RENAME TO "SpecialistProfile";
CREATE UNIQUE INDEX "SpecialistProfile_userId_key" ON "SpecialistProfile"("userId");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
