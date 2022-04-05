'use strict';

const modules_scene_index = require('../scene/index.js');

const NullMakeup = "modules/makeup/MakeupNull.png";

const Blushes = "modules/makeup/blushes.ktx";

const Contour = "modules/makeup/contour.ktx";

const Lashes = "modules/makeup/eyelashes_makeup.ktx";

const Eyeliner = "modules/makeup/eyeliner.ktx";

const Eyeshadow = "modules/makeup/eyeshadow.ktx";

const Highlighter = "modules/makeup/highlighter.ktx";

const vertexShader = "modules/makeup/makeup.vert";

const fragmentShader = "modules/makeup/makeup.frag";

class Makeup {
    constructor() {
        Object.defineProperty(this, "_makeup", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader,
                fragmentShader,
                uniforms: {
                    tex_contour: new modules_scene_index.Image(NullMakeup),
                    tex_blushes: new modules_scene_index.Image(NullMakeup),
                    tex_highlighter: new modules_scene_index.Image(NullMakeup),
                    tex_eyeshadow: new modules_scene_index.Image(NullMakeup),
                    tex_eyeliner: new modules_scene_index.Image(NullMakeup),
                    tex_lashes: new modules_scene_index.Image(NullMakeup),
                    tex_makeup: new modules_scene_index.Image(NullMakeup),
                    var_contour_color: new modules_scene_index.Vector4(0, 0, 0, 1),
                    var_blushes_color: new modules_scene_index.Vector4(0, 0, 0, 1),
                    var_highlighter_color: new modules_scene_index.Vector4(0, 0, 0, 1),
                    var_eyeshadow_color: new modules_scene_index.Vector4(0, 0, 0, 1),
                    var_eyeliner_color: new modules_scene_index.Vector4(0, 0, 0, 1),
                    var_lashes_color: new modules_scene_index.Vector4(0, 0, 0, 1),
                },
            }))
        });
        this._makeup.visible(false);
        const onChange = () => {
            let isCorrectionNeeded = [
                this._makeup.material.uniforms.var_eyeshadow_color.value(),
                this._makeup.material.uniforms.var_eyeliner_color.value(),
                this._makeup.material.uniforms.var_lashes_color.value(),
            ].some(([, , , a]) => a > 0);
            if (isCorrectionNeeded)
                modules_scene_index.enable("EYES_CORRECTION", this);
            else
                modules_scene_index.disable("EYES_CORRECTION", this);
        };
        this._makeup.material.uniforms.var_eyeshadow_color.subscribe(onChange);
        this._makeup.material.uniforms.var_eyeliner_color.subscribe(onChange);
        this._makeup.material.uniforms.var_lashes_color.subscribe(onChange);
        modules_scene_index.add(this._makeup);
    }
    set(filename) {
        this._makeup.visible(true);
        this._makeup.material.uniforms.tex_makeup.load(filename);
    }
    contour(value) {
        this._makeup.visible(true);
        if (isUrl(value)) {
            this._makeup.material.uniforms.tex_contour.load(value);
            return;
        }
        if (this._makeup.material.uniforms.tex_contour.filename === NullMakeup) {
            this._makeup.material.uniforms.tex_contour.load(Contour);
        }
        this._makeup.material.uniforms.var_contour_color.value(value);
    }
    blushes(value) {
        this._makeup.visible(true);
        if (isUrl(value)) {
            this._makeup.material.uniforms.tex_blushes.load(value);
            return;
        }
        if (this._makeup.material.uniforms.tex_blushes.filename === NullMakeup) {
            this._makeup.material.uniforms.tex_blushes.load(Blushes);
        }
        this._makeup.material.uniforms.var_blushes_color.value(value);
    }
    highlighter(value) {
        this._makeup.visible(true);
        if (isUrl(value)) {
            this._makeup.material.uniforms.tex_highlighter.load(value);
            return;
        }
        if (this._makeup.material.uniforms.tex_highlighter.filename === NullMakeup) {
            this._makeup.material.uniforms.tex_highlighter.load(Highlighter);
        }
        this._makeup.material.uniforms.var_highlighter_color.value(value);
    }
    eyeshadow(value) {
        this._makeup.visible(true);
        if (isUrl(value)) {
            this._makeup.material.uniforms.tex_eyeshadow.load(value);
            return;
        }
        if (this._makeup.material.uniforms.tex_eyeshadow.filename === NullMakeup) {
            this._makeup.material.uniforms.tex_eyeshadow.load(Eyeshadow);
        }
        this._makeup.material.uniforms.var_eyeshadow_color.value(value);
    }
    eyeliner(value) {
        this._makeup.visible(true);
        if (isUrl(value)) {
            this._makeup.material.uniforms.tex_eyeliner.load(value);
            return;
        }
        if (this._makeup.material.uniforms.tex_eyeliner.filename === NullMakeup) {
            this._makeup.material.uniforms.tex_eyeliner.load(Eyeliner);
        }
        this._makeup.material.uniforms.var_eyeliner_color.value(value);
    }
    lashes(value) {
        this._makeup.visible(true);
        if (isUrl(value)) {
            this._makeup.material.uniforms.tex_lashes.load(value);
            return;
        }
        if (this._makeup.material.uniforms.tex_lashes.filename === NullMakeup) {
            this._makeup.material.uniforms.tex_lashes.load(Lashes);
        }
        this._makeup.material.uniforms.var_lashes_color.value(value);
    }
    /** Removes the eyes color, resets any settings applied */
    clear() {
        this.set(NullMakeup);
        this.contour("0 0 0 0");
        this.contour(NullMakeup);
        this.blushes("0 0 0 0");
        this.blushes(NullMakeup);
        this.highlighter("0 0 0 0");
        this.highlighter(NullMakeup);
        this.eyeshadow("0 0 0 0");
        this.eyeshadow(NullMakeup);
        this.eyeliner("0 0 0 0");
        this.eyeliner(NullMakeup);
        this.lashes("0 0 0 0");
        this.lashes(NullMakeup);
        this._makeup.visible(false);
    }
}
function isUrl(str) {
    return /^\S+\.\w+$/.test(str);
}

exports.Makeup = Makeup;
