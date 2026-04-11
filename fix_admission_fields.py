import re

with open('admission-form.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Make applicant_name_armenian conditional in buildApplicationRecord
build_app_rec_old = """function buildApplicationRecord(baseRecord, data, includeDocumentFields, includeCredentialFields) {
  const record = { ...baseRecord };

  if (includeDocumentFields) {
    if (data.documentId) record.document_id = data.documentId;
    if (data.controlNumber) record.control_number = data.controlNumber;
    if (data.verificationHash) record.verification_hash = data.verificationHash;
  }"""

build_app_rec_new = """function buildApplicationRecord(baseRecord, data, includeDocumentFields, includeCredentialFields) {
  const record = { ...baseRecord };

  if (includeDocumentFields) {
    if (data.documentId) record.document_id = data.documentId;
    if (data.controlNumber) record.control_number = data.controlNumber;
    if (data.verificationHash) record.verification_hash = data.verificationHash;
    if (data.fullNameArmenian) record.applicant_name_armenian = data.fullNameArmenian;
  }"""

content = content.replace(build_app_rec_old, build_app_rec_new)

# Remove applicant_name_armenian from baseRecord
baserecord_old = """    hash: data.verificationHash,
    applicant_name: data.applicantName,
    applicant_name_armenian: data.fullNameArmenian || null,
    email: data.email,"""

baserecord_new = """    hash: data.verificationHash,
    applicant_name: data.applicantName,
    email: data.email,"""

content = content.replace(baserecord_old, baserecord_new)

with open('admission-form.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Applied fix.")
