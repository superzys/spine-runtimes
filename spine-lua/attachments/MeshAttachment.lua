-------------------------------------------------------------------------------
-- Spine Runtimes License Agreement
-- Last updated May 1, 2019. Replaces all prior versions.
--
-- Copyright (c) 2013-2019, Esoteric Software LLC
--
-- Integration of the Spine Runtimes into software or otherwise creating
-- derivative works of the Spine Runtimes is permitted under the terms and
-- conditions of Section 2 of the Spine Editor License Agreement:
-- http://esotericsoftware.com/spine-editor-license
--
-- Otherwise, it is permitted to integrate the Spine Runtimes into software
-- or otherwise create derivative works of the Spine Runtimes (collectively,
-- "Products"), provided that each user of the Products must obtain their own
-- Spine Editor license and redistribution of the Products in any form must
-- include this license and copyright notice.
--
-- THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY DIRECT, INDIRECT,
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
-- BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, BUSINESS
-- INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
-- EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

local setmetatable = setmetatable
local AttachmentType = require "spine-lua.attachments.AttachmentType"
local VertexAttachment = require "spine-lua.attachments.VertexAttachment"
local utils = require "spine-lua.utils"
local Color = require "spine-lua.Color"

local MeshAttachment = {}
MeshAttachment.__index = MeshAttachment
setmetatable(MeshAttachment, { __index = VertexAttachment })

function MeshAttachment.new (name)
	if not name then error("name cannot be nil", 2) end

	local self = VertexAttachment.new(name, AttachmentType.mesh)
	self.region = nil
	self.path = nil
	self.regionUVs = nil
	self.uvs = nil
	self.triangles = nil
	self.color = Color.newWith(1, 1, 1, 1)
	self.hullLength = 0
	self.parentMesh = nil
	self.inheritDeform = false
	self.tempColor = Color.newWith(1, 1, 1, 1)
	setmetatable(self, MeshAttachment)
	return self
end

function MeshAttachment:updateUVs ()
	local u = 0
	local v = 0
	local width = 0
	local height = 0
	if not self.region then
		u = 0
		v = 0
		width = 1
		height = 1
	else
		local region = self.region
		local textureWidth = region.page.width
		local textureHeight = region.page.height
		if region.rotate then
			u = region.u - (region.originalHeight - region.offsetY - region.height) / textureWidth
			v = region.v - (region.originalWidth - region.offsetX - region.width) / textureHeight
				width = region.originalHeight / textureWidth
				height = region.originalWidth / textureHeight
		else
			u = region.u - region.offsetX / textureWidth;
			v = region.v - (region.originalHeight - region.offsetY - region.height) / textureHeight;
			width = region.originalWidth / textureWidth;
			height = region.originalHeight / textureHeight;
		end
	end
	
	local regionUVs = self.regionUVs
	if not self.uvs or (#self.uvs ~= #regionUVs) then self.uvs = utils.newNumberArray(#regionUVs) end
	local uvs = self.uvs
	
	if self.region and self.region.rotate then
		local i = 0
		local n = #uvs
		while i < n do
			uvs[i + 1] = u + regionUVs[i + 2] * width;
			uvs[i + 2] = v + height - regionUVs[i + 1] * height;
			i = i + 2
		end
	else
		local i = 0
		local n = #uvs
		while i < n do
			uvs[i + 1] = u + regionUVs[i + 1] * width;
			uvs[i + 2] = v + regionUVs[i + 2] * height;
			i = i + 2
		end
	end
end

function MeshAttachment:applyDeform (sourceAttachment)
	return self == sourceAttachment or (self.inheritDeform and self.parentMesh == sourceAttachment)
end

function MeshAttachment:setParentMesh (parentMesh)
	self.parentMesh = parentMesh
	if parentMesh then
		self.bones = parentMesh.bones
		self.vertices = parentMesh.vertices
		self.worldVerticesLength = parentMesh.worldVerticesLength
		self.regionUVs = parentMesh.regionUVs
		self.triangles = parentMesh.triangles
		self.hullLength = parentMesh.hullLength
	end
end

return MeshAttachment
